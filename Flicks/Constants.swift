//
//  Constants.swift
//  Flicks
//
//  Created by Dylan Miller on 10/13/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

struct Constants
{
    struct TMDB
    {
        static let ApiScheme = "https"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = "/3"
    }
    
    struct TMDBPathExtensions
    {    
        static let GetNowPlaying = "/movie/now_playing"
        static let GetTopRated = "/movie/top_rated"
    }
    
    struct TMDBParameterKeys
    {
        static let ApiKey = "api_key"
        static let Language = "language"
    }
    
    struct TMDBParameterValues
    {
        static let ApiKey = "c5464f775ab54c800db05925546edf58"
        static let Language = "en-US"
    }
    
    struct TMDBResponseKeys
    {
        static let Title = "title"
        static let ID = "id"
        static let Overview = "overview"
        static let PosterPath = "poster_path"
        static let Results = "results"
    }
    
    struct TMDBImageBaseUrls
    {
        static let Small = "http://image.tmdb.org/t/p/w185"
        static let Large = "http://image.tmdb.org/t/p/w780"
    }
}
