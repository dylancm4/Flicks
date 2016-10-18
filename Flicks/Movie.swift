//
//  Movies.swift
//  Flicks
//
//  Created by Dylan Miller on 10/12/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

struct Movie
{
    let id: Int?
    let title: String?
    let overview: String?
    let posterPath: String?
    
    var posterSmallImageUrl: URL?
    {
        if let posterPath = posterPath
        {
            return URL(string: Constants.TMDBImageBaseUrls.Small + posterPath)
        }
        else
        {
            return nil
        }
    }
    
    var posterLargeImageUrl: URL?
    {
        if let posterPath = posterPath
        {
            return URL(string: Constants.TMDBImageBaseUrls.Large + posterPath)
        }
        else
        {
            return nil
        }
    }
        
    init(dictionary: [String:AnyObject])
    {
        id = dictionary[Constants.TMDBResponseKeys.ID] as? Int
        title = dictionary[Constants.TMDBResponseKeys.Title] as? String
        overview = dictionary[Constants.TMDBResponseKeys.Overview] as? String
        posterPath = dictionary[Constants.TMDBResponseKeys.PosterPath] as? String
    }
    
    // Returns an array of Movie objects based on the specified results array
    // of dictionaries.
    static func moviesFromResults(_ results: [[String:AnyObject]]) -> [Movie]
    {
        var movies = [Movie]()
        
        for result in results
        {
            movies.append(Movie(dictionary: result))
        }
        
        return movies
    }
}



