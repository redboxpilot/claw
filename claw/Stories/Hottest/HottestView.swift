import Foundation
import SwiftUI

struct HottestView: View {
    @ObservedObject var hottest = HottestFetcher()
    @EnvironmentObject var settings: Settings
    @Environment(\.didReselect) var didReselect
    @State var isVisible = false
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Divider().padding(0).padding([.leading])
                    if hottest.stories.count <= 0 {
                        ForEach(1..<10) { _ in
                            StoryListCellView(story: NewestStory.placeholder).environmentObject(settings).redacted(reason: .placeholder).allowsTightening(false)
                        }
                        Divider().padding(0).padding([.leading])
                    }
                    ForEach(hottest.stories) { story in
                        StoryListCellView(story: story).id(story).environmentObject(settings).onAppear(perform: {
                            self.hottest.more(story)
                        })
                        Divider().padding(0).padding([.leading])
                    }
                    if hottest.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }.onDisappear(perform: {
                    self.isVisible = false
                }).onAppear(perform: {
                    self.isVisible = true
                }).navigationBarTitle("Hottest").onReceive(didReselect) { _ in
                    DispatchQueue.main.async {
                        if self.isVisible {
                            withAnimation {
                                scrollProxy.scrollTo(hottest.stories.first)
                            }
                        }
                    }
                }.navigationBarItems(trailing: Button(action: { hottest.reload() }, label: {
                    if self.hottest.isReloading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }))
            }
        }
    }
}
