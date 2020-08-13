//
//  ContentView.swift
//  Unsplash The Kraken
//
//  Created by Rasyid Respati Wiriaatmaja on 18/06/20.
//  Copyright © 2020 rasyidrw. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @State var expand = false
    @State var search = ""
    @ObservedObject var RandomImages = getData()
    @State var page = 1
    @State var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                
                //Hiding this view when search bar is expanded
                if !self.expand {
                    
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Unsplash Apps")
                            .font(.title)
                            .fontWeight(.bold)
                        
                    }
                    .foregroundColor(.black)
                    
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        
                        withAnimation{
                            
                            self.expand = true
                            
                        }
                }
                
                //Display textfield when searchbar is expanded
                if self.expand{
                    
                    TextField("Search...", text: self.$search)
                    
                    //Display close button
                    //Display search button when search bar is not empty
                    
                    if self.search != "" {
                        Button(action: {
                            
                            //Search content
                            //Delete all existing data and display search data
                            
                            self.RandomImages.Images.removeAll()
                            
                            self.isSearching = true
                            
                            self.page = 1
                            
                            self.searchData()
                            
                        }) {
                            
                            Text("Search")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Button(action: {
                        
                        withAnimation{
                            self.expand = false
                        }
                        
                        self.search = ""
                        
                        if self.isSearching {
                            
                            self.isSearching = false
                            self.RandomImages.Images.removeAll()
                            self.RandomImages.updateData()
                        }
                        
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 10)
                }
                
                
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(Color.white)
            
            if self.RandomImages.Images.isEmpty {
                
                //Data is loading
                //or no data
                
                Spacer()
                
                if self.RandomImages.noresults {
                    
                    Text("No results found")
                } else {
                    
                    Indicator()
                }
                
                Spacer()
                
            } else {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    //Collection view
                    VStack(spacing: 15) {
                        
                        ForEach(self.RandomImages.Images,id: \.self) {
                            i in HStack(spacing: 20) {
                                
                                ForEach(i) {
                                    j in AnimatedImage(url: URL(string: j.urls["thumb"]!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 200)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        
                        //Create "More" button
                        if !self.RandomImages.Images.isEmpty {
                            
                            if self.isSearching && self.search != "" {
                                
                                HStack {
                                    
                                    Text("Page \(self.page)")
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        //Updating data
                                        self.RandomImages.Images.removeAll()
                                        self.page += 1
                                        self.searchData()
                                        
                                    }) {
                                        
                                        Text("More..")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                    }
                                }
                                .padding(.horizontal, 25)
                                
                            } else {
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        //Updating data
                                        self.RandomImages.Images.removeAll()
                                        self.RandomImages.updateData()
                                        
                                    }) {
                                        
                                        Text("More..")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                    }
                                }
                                .padding(.horizontal, 25)
                                
                            }
                        }
                    }
                    .padding(.top)
                    
                }
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
        
    }
    
    func searchData() {
        
        let key = "UlWgIpdTFQIqfnoXuFvc0lTkSaOY3D1bOuvHT7bIUzU"
        
        //Replacing query spaces into %20
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        
        //Update page
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&query=\(query)&client_id=\(key)"
        
        self.RandomImages.observeData(url: url)
    }
}

//Fetching data
class getData : ObservableObject {
    
    //Create Collection View
    @Published var Images : [[Photo]] = []
    @Published var noresults = false
    
    init() {
        
        //Initial data
        updateData()
    }
    
    func updateData(){
        
        self.noresults = false
        
        let key = "UlWgIpdTFQIqfnoXuFvc0lTkSaOY3D1bOuvHT7bIUzU"
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            //JSON Decoding
            do{
                let json = try JSONDecoder().decode([Photo].self, from: data!)
                
                //Create collection view, each row has two views
                for i in stride(from: 0, to: json.count, by: 2) {
                    
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        
                        //Index of bound
                        if j < json.count {
                            
                            ArrayData.append(json[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.Images.append(ArrayData)
                    }
                    
                }
                
            } catch {
                print(error.localizedDescription)
                
            }
        }
        .resume()
        
    }
    
    func observeData(url: String){
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            //JSON Decoding
            do{
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                
                if json.results.isEmpty {
                    self.noresults = true
                    
                } else {
                    self.noresults = false
                    
                }
                
                //Create collection view, each row has two views
                for i in stride(from: 0, to: json.results.count, by: 2) {
                    
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        
                        //Index of bound
                        if j < json.results.count {
                            
                            ArrayData.append(json.results[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.Images.append(ArrayData)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
                
            }
        }
        .resume()
    }
}

struct Photo : Identifiable, Decodable, Hashable {
    
    var id : String
    var urls : [String : String]
    
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
        
    }
}

//Model for search
struct SearchPhoto : Decodable {
    
    var results : [Photo]
}
