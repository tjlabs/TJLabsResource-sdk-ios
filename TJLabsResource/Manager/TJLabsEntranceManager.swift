
import Foundation

protocol EntranceDelegate: AnyObject {
    func onEntranceData(_ manager: TJLabsEntranceManager, isOn: Bool, entranceKey: String, data: EntranceData?)
    func onEntranceRouteData(_ manager: TJLabsEntranceManager, isOn: Bool, entranceKey: String, data: EntranceRouteData?)
    func onEntranceError(_ manager: TJLabsEntranceManager)
}

class TJLabsEntranceManager {
    
    static var entranceDataMap = [String: EntranceData]()
    static var entranceRouteDataMap = [String: EntranceRouteData]()
    static var entranceRouteDataLoaded = [String: EntranceRouteDataIsLoaded]()
    weak var delegate: EntranceDelegate?
    
    var region: String = ResourceRegion.KOREA.rawValue
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadEntrance(region: String, sectorId: Int) {
        postUserEntrance(input: SectorIdOsInput(sector_id: sectorId, operating_system: "iOS"), completion: { [self] isSuccess, msg, entranceRouteUrl in
            if isSuccess {
                // 성공
                for (key, value) in entranceRouteUrl {
                    let entranceRouteUrlFromServer = value
                    if let entranceRouteUrlFromCache = loadEntranceRouteUrlFromCache(key: key) {
                        if entranceRouteUrlFromServer == entranceRouteUrlFromCache {
                            // 버전이 같다면
                            if let fileUrlFromCache = self.loadEntranceRouteFileUrlFromCache(key: key) {
                                // Cache에서 파일 URL 가져오기 성공
                                do {
                                    let contents = try String(contentsOf: fileUrlFromCache)
                                    let parsedData = self.parseEntranceRoute(data: contents)
                                    let entranceRouteData = EntranceRouteData(routeLevel: parsedData.0, route: parsedData.1)
                                    TJLabsEntranceManager.entranceRouteDataMap[key] = entranceRouteData
                                    TJLabsEntranceManager.entranceRouteDataLoaded[key] = EntranceRouteDataIsLoaded(isLoaded: true, URL: entranceRouteUrlFromServer)
                                    delegate?.onEntranceRouteData(self, isOn: true, entranceKey: key, data: entranceRouteData)
                                } catch {
                                    updateEntranceRoute(key: key, entranceRouteUrlFromServer: entranceRouteUrlFromServer)
                                }
                            } else {
                                // Cache에서 파일 URL 가져오기 실패
                                updateEntranceRoute(key: key, entranceRouteUrlFromServer: entranceRouteUrlFromServer)
                            }
                        } else {
                            // 버전이 다르다면 서버에서 다운로드
                            updateEntranceRoute(key: key, entranceRouteUrlFromServer: entranceRouteUrlFromServer)
                        }
                    } else {
                        // Cache에 저장된 정보 없음
                        updateEntranceRoute(key: key, entranceRouteUrlFromServer: entranceRouteUrlFromServer)
                    }
                }
                print("(TJLabsResource) Success : loadEntrance")
            } else {
                delegate?.onEntranceError(self)
                print("(TJLabsResource) Fail : loadEntrance")
            }
        })
    }
    
    func updateEntranceRoute(key: String, entranceRouteUrlFromServer: String) {
        let urlComponents = URLComponents(string: entranceRouteUrlFromServer)
        TJLabsFileDownloader.shared.downloadCSVFile(from: (urlComponents?.url)!, fname: key, completion: { [self] url, error in
            if error == nil {
                do {
                    let contents = try String(contentsOf: url!)
                    let parsedData = self.parseEntranceRoute(data: contents)
                    let entranceRouteData = EntranceRouteData(routeLevel: parsedData.0, route: parsedData.1)
                    TJLabsEntranceManager.entranceRouteDataMap[key] = entranceRouteData
                    TJLabsEntranceManager.entranceRouteDataLoaded[key] = EntranceRouteDataIsLoaded(isLoaded: true, URL: entranceRouteUrlFromServer)
                    self.saveEntranceRouteUrlToCache(key: key, entranceRouteUrlFromServer: entranceRouteUrlFromServer)
                    delegate?.onEntranceRouteData(self, isOn: true, entranceKey: key, data: entranceRouteData)
                } catch {
                    TJLabsEntranceManager.entranceRouteDataLoaded[key] = EntranceRouteDataIsLoaded(isLoaded: false, URL: entranceRouteUrlFromServer)
                    delegate?.onEntranceRouteData(self, isOn: false, entranceKey: key, data: nil)
                }
            } else {
                TJLabsEntranceManager.entranceRouteDataLoaded[key] = EntranceRouteDataIsLoaded(isLoaded: false, URL: entranceRouteUrlFromServer)
                delegate?.onEntranceRouteData(self, isOn: false, entranceKey: key, data: nil)
            }
        })
    }
    
    func loadEntranceRouteFileUrlFromCache(key: String) -> URL? {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedURL = documentsURL.appendingPathComponent("\(self.region)/\(key).csv")
            
            if FileManager.default.fileExists(atPath: savedURL.path) {
                print("(TJLabsResource) Info : Entrance Route \(key).csv exists")
                return savedURL
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func loadEntranceRouteUrlFromCache(key: String) -> String? {
        let keyEntranceRouteURL: String = "TJLabsEntranceRouteURL_\(key)"
        if let loadedEntranceRouteURL: String = UserDefaults.standard.object(forKey: keyEntranceRouteURL) as? String {
            return loadedEntranceRouteURL
        } else {
            return nil
        }
    }
    
    func saveEntranceRouteUrlToCache(key: String, entranceRouteUrlFromServer: String) {
        print("(TJLabsResource) Info : save \(key) Entrance Route URL \(entranceRouteUrlFromServer)")
        do {
            let key: String = "TJLabsEntranceRouteURL_\(key)"
            UserDefaults.standard.set(entranceRouteUrlFromServer, forKey: key)
        }
    }
    
    func postUserEntrance(input: SectorIdOsInput, completion: @escaping (Bool, String, [String: String]) -> Void) {
       var entranceRouteURL = [String: String]()
        let entranceURL = TJLabsResourceNetworkConstants.getUserEntranceURL()
        TJLabsResourceNetworkManager.shared.postEntranceRoute(url: entranceURL, input: input, completion: { [self] statusCode, returnedString, input in
            if statusCode == 200 {
                let outputEntrance = decodeOutputEntrance(jsonString: returnedString)
                if outputEntrance.0 {
                    //MARK: - Entrance
                    let outputEntranceList = outputEntrance.1
                    var entranceInfoList: [EntranceInfo] = []
                    for element in outputEntranceList.entrance_list {
                        let buildingName = element.building_name
                        let levelName = element.level_name
                        let key = "\(input.sector_id)_\(buildingName)_\(levelName)"
                        
                        let entrances = element.entrances
                        for ent in entrances {
                            let entranceKey = "\(key)_\(ent.spot_number)"
                            let entranceInfo = EntranceInfo(building: buildingName, level: levelName, number: ent.spot_number, networkStatus: ent.network_status, velocityScale: ent.scale, innerWardId: ent.innermost_ward.id, innerWardRssi: ent.innermost_ward.rss, innerWardCoord: ent.innermost_ward.pos + [ent.innermost_ward.direction], outerWardId: ent.outermost_ward_id)
                            entranceInfoList.append(entranceInfo)
                            entranceRouteURL[entranceKey] = ent.url
                        }
                    }
                    
                    let key = "\(input.sector_id)"
                    let entranceData = EntranceData(entranceInfoList: entranceInfoList)
                    TJLabsEntranceManager.entranceDataMap[key] = entranceData
                    delegate?.onEntranceData(self, isOn: true, entranceKey: key, data: entranceData)
                    let msg = "(TJLabsResource) Success : Load Sector Info // Entrance"
                    completion(true, msg, entranceRouteURL)
                } else {
                    let msg = "(TJLabsResource) Error : Load Sector Info // Entrance \(statusCode)"
                    completion(false, msg, entranceRouteURL)
                }
            } else {
                let msg = "(TJLabsResource) Error : Load Sector Info // Entrance \(statusCode)"
                completion(false, msg, entranceRouteURL)
            }
        })
    }

    
    // MARK: - Decode Entrance output
    func decodeOutputEntrance(jsonString: String) -> (Bool, EntranceOutputList) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return (false, EntranceOutputList(entrance_list: []))
        }
        
        do {
            let decodedData = try JSONDecoder().decode(EntranceOutputList.self, from: jsonData)
            return (true, decodedData)
        } catch {
            print("Error decoding JSON: \(error)")
            return (false, EntranceOutputList(entrance_list: []))
        }
    }
    
    // MARK: - Parsing
    private func parseEntranceRoute(data: String) -> ([String], [[Double]]) {
        var entracneLevelArray = [String]()
        var entranceArray = [[Double]]()

        let entranceString = data.components(separatedBy: .newlines)
        for i in 0..<entranceString.count {
            if (entranceString[i] != "") {
                let lineData = entranceString[i].components(separatedBy: ",")
                
                let entrance: [Double] = [(Double(lineData[1])!), (Double(lineData[2])!), (Double(lineData[3])!)]
                
                entracneLevelArray.append(lineData[0])
                entranceArray.append(entrance)
            }
        }
        return (entracneLevelArray, entranceArray)
    }
}
