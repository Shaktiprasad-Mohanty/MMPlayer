//
//  MMPlayerTests.swift
//  MMPlayerTests
//
//  Created by Shaktiprasad Mohanty on 25/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import XCTest
@testable import MMPlayer

var player : MMPlayer?
class MMPlayerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        player = MMPlayer(URL: url)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        player = nil
    }

    func testPlay() {
        player?.play()
    }
    
    func testPause()  {
        player?.pause()
    }
    
    func testSeekForward() {
        player?.seekTime(120)
    }
    
    func testDataSavingInCoredate() {
        VideoDBM.shared.checkAndSaveVideos()
    }
    func testCoredata() {
        let coresalVideos = VideoDBM.shared.fetchForCoresal()
        XCTAssertEqual(coresalVideos.count, 5)
        let newVideoCount = VideoDBM.shared.fetchForNewRelease().count
        XCTAssertEqual(newVideoCount, 10)
        let trendingVideoCount = VideoDBM.shared.fetchForTreding().count
        XCTAssertEqual(trendingVideoCount, 10)
        VideoDBM.shared.updateFavValue(isFav: true, for: coresalVideos[0].id!)
        XCTAssertEqual(coresalVideos[0].is_fav, true)
        VideoDBM.shared.updateFavValue(isFav: false, for: coresalVideos[0].id!)
        XCTAssertEqual(coresalVideos[0].is_fav, false)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
