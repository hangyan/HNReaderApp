//
//  ItemCell.swift
//  HNReader
//
//  Created by Mattia Righetti on 12/06/21.
//

import SwiftUI

struct ItemCell: View {
    var itemId: Int
    let itemDownloader: ItemDownloader

    @Environment(\.colorScheme) var colorScheme
    @State var item: Item?

    init(itemId: Int) {
        self.itemId = itemId
        itemDownloader = DefaultItemDownloader(itemId: itemId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TitleView()
            HostText()
            
//            if let text = item.text {
//                HTMLText(text: text)
//                    .font(.body)
//                    .lineLimit(3)
//                    .multilineTextAlignment(.leading)
//            }
            
            HStack {
                ScoreText()
                AuthorText()
                Spacer()
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .onAppear {
            if item == nil {
                fetchItem()
            }
        }
        .onTapGesture {
            if let item = item {
                guard let url = URL(string: item.url!) else { return }
                NSWorkspace.shared.open(url)
            }
        }
    }

    @ViewBuilder
    private func TitleView() -> some View {
        if let item = item {
            Text(item.title ?? "No title")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
        } else {
            Text("No title")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private func HostText() -> some View {
        if let item = item {
            Text(item.urlHost ?? "")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        } else {
            Text("No url")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private func ScoreText() -> some View {
        if let item = item {
            Text("\(item.score ?? 0)")
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.orange)
                .fontWeight(.bold)
        } else {
            Text("0")
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.orange)
                .fontWeight(.bold)
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private func AuthorText() -> some View {
        HStack {
            Text("•")
                .padding(.horizontal, 1)
            Text("Posted by")
                .foregroundColor(.gray)
            if let item = item {
                Text("\(item.by ?? "anonymous")")
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
            } else {
                Text("No author")
                    .redacted(reason: .placeholder)
            }
            Text("•")
                .padding(.horizontal, 1)
            if let item = item {
                Text("\(item.timeStringRepresentation ?? "")")
                    .foregroundColor(.gray)
            } else {
                Text("").redacted(reason: .placeholder)
            }
        }
        .font(.system(.callout, design: .rounded))
    }

    private func fetchItem() {
        let cacheKey = itemId
        if let cachedItem = ItemCache.shared.getItem(for: cacheKey) {
            self.item = cachedItem
        } else {
            itemDownloader.downloadItem(completion: { item in
                guard let item = item else { return }
                ItemCache.shared.cache(item, for: cacheKey)
                DispatchQueue.main.async {
                    self.item = item
                }
            })
        }
    }
}

struct ItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ItemCell(itemId: 27492268)
    }
}
