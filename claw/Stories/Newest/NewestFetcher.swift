//
//  newest.swift
//  claw
//
//  Created by Zachary Gorak on 9/11/20.
//

import Foundation
import SwiftUI

class NewestFetcher: ObservableObject {
    @Published var stories = NewestFetcher.cachedStories
    static var cachedStories = [NewestStory]()
    @Published var isLoadingMore = false
    @Published var isReloading = false
    var page: Int = 1
    
    init() {
        load()
    }
    
    deinit {
        self.session?.cancel()
        self.moreSession?.cancel()
    }
    
    private var session: URLSessionTask? = nil
    private var moreSession: URLSessionTask? = nil
    
    func reload(completion: ((Error?)->Void)? = nil) {
        self.session?.cancel()
        self.isReloading = true
        self.page = 1
        self.load(completion: { error in
            self.isReloading = false
            completion?(error)
        })
    }
    
    func load(completion: ((Error?)->Void)? = nil) {
        let url = URL(string: "https://lobste.rs/newest.json?page=\(self.page)")!
    self.session = URLSession.shared.dataTask(with: url) {(data,response,error) in
                do {
                    if let d = data {
                        let decodedLists = try JSONDecoder().decode([NewestStory].self, from: d)
                        DispatchQueue.main.async {
                            NewestFetcher.cachedStories = decodedLists
                            self.stories = decodedLists
                            self.page += 1
                            completion?(nil)
                        }
                    }else {
                        print("No Data")
                        completion?(nil) // todo: throw error
                    }
                } catch {
                    print ("Error \(error)")
                    completion?(error)
                }
            }
        self.session?.resume()
    }
    
    func more(_ story: NewestStory? = nil, completion: ((Error?)->Void)? = nil) {
        if self.stories.last == story && !isLoadingMore {
            let url = URL(string: "https://lobste.rs/newest.json?page=\(self.page)")!
            self.isLoadingMore = true

            self.moreSession = URLSession.shared.dataTask(with: url) { (data,response,error) in
                do {
                    if let d = data {
                        let decodedLists = try JSONDecoder().decode([NewestStory].self, from: d)
                        DispatchQueue.main.async {
                            let stories = decodedLists
                            for story in stories {
                                if !self.stories.contains(story) {
                                    self.stories.append(story)
                                }
                            }
                            NewestFetcher.cachedStories = self.stories
                            self.page += 1
                            completion?(nil)
                        }
                    }else {
                        print("No Data")
                        completion?(nil) // todo: actually do error
                    }
                } catch {
                    print ("Error \(error)")
                    completion?(error)
                }
                DispatchQueue.main.async {
                    self.isLoadingMore = false
                }
            }
            self.moreSession?.resume()
        }
    }
}
