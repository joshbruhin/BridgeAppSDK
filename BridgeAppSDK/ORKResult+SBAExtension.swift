//
//  ORKResult+SBAExtension.swift
//  BridgeAppSDK
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import ResearchKit

private var kStartDateKey = "startDate"
private var kEndDateKey = "endDate"
private var kIdentifierKey = "identifier"

private var kItemKey = "item"

private var kTappingViewSizeKey = "TappingViewSize"
private var kButtonRectLeftKey = "ButtonRectLeft"
private var kButtonRectRightKey = "ButtonRectRight"
private var kTapTimeStampKey = "TapTimeStamp"
private var kTapCoordinateKey = "TapCoordinate"
private var kTappedButtonIdKey = "TappedButtonId"
private var kTappedButtonNoneKey = "TappedButtonNone"
private var kTappedButtonLeftKey = "kTappedButtonLeftKey"
private var kTappedButtonRightKey = "TappedButtonRight"
private var kTappingSamplesKey = "TappingSamples"

private var kSpatialSpanMemoryGameStatusKey = "MemoryGameStatus"
private var kSpatialSpanMemoryGameStatusUnknownKey = "MemoryGameStatusUnknown"
private var kSpatialSpanMemoryGameStatusSuccessKey = "MemoryGameStatusSuccess"
private var kSpatialSpanMemoryGameStatusFailureKey = "MemoryGameStatusFailure"
private var kSpatialSpanMemoryGameStatusTimeoutKey = "MemoryGameStatusTimeout"

private var kSpatialSpanMemorySummaryNumberOfGamesKey = "MemoryGameNumberOfGames"
private var kSpatialSpanMemorySummaryNumberOfFailuresKey = "MemoryGameNumberOfFailures"
private var kSpatialSpanMemorySummaryOverallScoreKey = "MemoryGameOverallScore"
private var kSpatialSpanMemorySummaryGameRecordsKey = "MemoryGameGameRecords"

private var kSpatialSpanMemoryGameRecordSeedKey = "MemoryGameRecordSeed"
private var kSpatialSpanMemoryGameRecordGameSizeKey = "MemoryGameRecordGameSize"
private var kSpatialSpanMemoryGameRecordGameScoreKey = "MemoryGameRecordGameScore"
private var kSpatialSpanMemoryGameRecordSequenceKey = "MemoryGameRecordSequence"
private var kSpatialSpanMemoryGameRecordTouchSamplesKey = "MemoryGameRecordTouchSamples"
private var kSpatialSpanMemoryGameRecordTargetRectsKey = "MemoryGameRecordTargetRects"

private var kSpatialSpanMemoryTouchSampleTimeStampKey = "MemoryGameTouchSampleTimestamp"
private var kSpatialSpanMemoryTouchSampleTargetIndexKey = "MemoryGameTouchSampleTargetIndex"
private var kSpatialSpanMemoryTouchSampleLocationKey = "MemoryGameTouchSampleLocation"
private var kSpatialSpanMemoryTouchSampleIsCorrectKey = "MemoryGameTouchSampleIsCorrect"

protocol BridgeUploadableData {
    func sba_bridgeData() -> NSData?
}

extension ORKResult: BridgeUploadableData {
    func sba_dataFromFile(fileURL: NSURL) -> NSData? {
        return NSData.init(contentsOfURL: fileURL)
    }
    
    func sba_dataFromDictionary(dictionary: Dictionary<String, AnyObject>) -> NSData? {
        let jsonData: NSData
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        } catch let error as NSError {
            fatalError("Failed to serialize JSON dictionary:\n\(error)")
        }
        
        return jsonData
    }
    
    func sba_bridgeData() -> NSData? {
        // extend subclasses individually to override this
        return nil
    }
}

extension ORKFileResult {
    override func sba_bridgeData() -> NSData? {
        guard let url = self.fileURL, let data = sba_dataFromFile(url) else {
            return nil
        }
        return data
    }
}

extension ORKTappingIntervalResult {
    
    override func sba_bridgeData() -> NSData? {
        var rawTappingResults: Dictionary<String, AnyObject> = [:]
    
        let tappingViewSize = NSStringFromCGSize(self.stepViewSize)
        rawTappingResults[kTappingViewSizeKey] = tappingViewSize
    
        rawTappingResults[kStartDateKey] = self.startDate
        rawTappingResults[kEndDateKey]   = self.endDate
    
        let leftButtonRect = NSStringFromCGRect(self.buttonRect1)
        rawTappingResults[kButtonRectLeftKey] = leftButtonRect;
    
        let rightButtonRect = NSStringFromCGRect(self.buttonRect2)
        rawTappingResults[kButtonRectRightKey] = rightButtonRect
    
        var sampleResults: [[String: AnyObject]] = []
        for sample in self.samples! {
            var aSampleDictionary = [String: AnyObject]();
            
            aSampleDictionary[kTapTimeStampKey]     = sample.timestamp;
            
            aSampleDictionary[kTapCoordinateKey]   = NSStringFromCGPoint(sample.location);
            
            if (sample.buttonIdentifier == ORKTappingButtonIdentifier.None) {
                aSampleDictionary[kTappedButtonIdKey] = kTappedButtonNoneKey
            } else if (sample.buttonIdentifier == ORKTappingButtonIdentifier.Left) {
                aSampleDictionary[kTappedButtonIdKey] = kTappedButtonLeftKey
            } else if (sample.buttonIdentifier == ORKTappingButtonIdentifier.Right) {
                aSampleDictionary[kTappedButtonIdKey] = kTappedButtonRightKey
            }
            sampleResults += [aSampleDictionary]
        }
        rawTappingResults[kTappingSamplesKey] = sampleResults
        rawTappingResults[kItemKey] = self.identifier + ".json";
        
        return sba_dataFromDictionary(rawTappingResults);
    }
}

extension ORKSpatialSpanMemoryResult {
    override func sba_bridgeData() -> NSData? {
        let gameStatusKeys = [ kSpatialSpanMemoryGameStatusUnknownKey, kSpatialSpanMemoryGameStatusSuccessKey, kSpatialSpanMemoryGameStatusFailureKey, kSpatialSpanMemoryGameStatusTimeoutKey ]
        
        var memoryGameResults = [String: AnyObject]();
        
        //
        //    ORK Result
        //
        memoryGameResults[kIdentifierKey] = self.identifier;
        memoryGameResults[kStartDateKey]  = self.startDate;
        memoryGameResults[kEndDateKey]    = self.endDate;
        //
        //    ORK ORKSpatialSpanMemoryResult
        //
        memoryGameResults[kSpatialSpanMemorySummaryNumberOfGamesKey]    = self.numberOfGames
        memoryGameResults[kSpatialSpanMemorySummaryNumberOfFailuresKey] = self.numberOfFailures
        memoryGameResults[kSpatialSpanMemorySummaryOverallScoreKey]     = self.score
        
        //
        //    Memory Game Records
        //
        var gameRecords = [[String: AnyObject]]();
        
        for aRecord: ORKSpatialSpanMemoryGameRecord in self.gameRecords! {
            
            var aGameRecord = [String: AnyObject]();
            
            aGameRecord[kSpatialSpanMemoryGameRecordSeedKey]      = Int(aRecord.seed)
            aGameRecord[kSpatialSpanMemoryGameRecordGameSizeKey]  = aRecord.gameSize
            aGameRecord[kSpatialSpanMemoryGameRecordGameScoreKey] = aRecord.score
            aGameRecord[kSpatialSpanMemoryGameRecordSequenceKey]  = aRecord.sequence
            aGameRecord[kSpatialSpanMemoryGameStatusKey]          = gameStatusKeys[aRecord.gameStatus.rawValue]
            
            let touchSamples = makeTouchSampleRecords(aRecord.touchSamples!)
            aGameRecord[kSpatialSpanMemoryGameRecordTouchSamplesKey] = touchSamples
            
            let rectangles = makeTargetRectangleRecords(aRecord.targetRects!)
            aGameRecord[kSpatialSpanMemoryGameRecordTargetRectsKey] = rectangles
            
            gameRecords += [aGameRecord]
        }
        memoryGameResults[kSpatialSpanMemorySummaryGameRecordsKey] = gameRecords
        memoryGameResults[kItemKey] = self.identifier + ".json"
        return sba_dataFromDictionary(memoryGameResults)
    }
    
    
    func makeTouchSampleRecords(touchSamples: [ORKSpatialSpanMemoryGameTouchSample]) -> NSArray
    {
        var samples = [[String: AnyObject]]()
        
        for sample: ORKSpatialSpanMemoryGameTouchSample in touchSamples {
            
            var aTouchSample = [String: AnyObject]()
            
            aTouchSample[kSpatialSpanMemoryTouchSampleTimeStampKey]   = sample.timestamp
            aTouchSample[kSpatialSpanMemoryTouchSampleTargetIndexKey] = sample.targetIndex
            aTouchSample[kSpatialSpanMemoryTouchSampleLocationKey]    = NSStringFromCGPoint(sample.location)
            aTouchSample[kSpatialSpanMemoryTouchSampleIsCorrectKey]   = sample.correct
            
            samples += [aTouchSample]
        }
        return  samples
    }
    
    func makeTargetRectangleRecords(targetRectangles: [NSValue]) -> NSArray
    {
        var rectangles = [String]()
        
        for value: NSValue in targetRectangles {
            let rectangle = value.CGRectValue()
            let stringified = NSStringFromCGRect(rectangle)
            rectangles += [stringified]
        }
        return  rectangles
    }
}

