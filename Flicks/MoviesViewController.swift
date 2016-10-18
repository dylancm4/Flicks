//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Dylan Miller on 10/12/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource
{
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var errorBannerView: UIView!

    var appDelegate: AppDelegate!
    var pathExtension: String!
    var movies = [Movie]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Get the AppDelegate.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Hide the error banner.
        errorBannerView.isHidden = true

        moviesTableView.rowHeight = 120.0
        
        // Create a UIRefreshControl and add it to the moviesTableView.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self, action: #selector(refreshControlAction(_:)),
            for: UIControlEvents.valueChanged)
        moviesTableView.insertSubview(refreshControl, at: 0)

        // Create an array of Movie objects retrieved from The Movie Database.
        tmdbGetMovies()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        
        // Initialize cell.
        cell.movieImageView?.image = nil
        cell.movieTitleLabel?.text = nil
        cell.movieOverviewLabel?.text = nil
        
        // Set the image and labels.
        let movie = movies[indexPath.row]
        if let posterUrl = movie.posterSmallImageUrl
        {
            let imageRequest = URLRequest(url: posterUrl)
            cell.movieImageView?.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // Fade in the image if it is not cached, or simply
                    // update the image if it was cached.
                    let imageIsCached = imageResponse == nil
                    if !imageIsCached
                    {
                        //print("Image was NOT cached, fade in image.")
                        cell.movieImageView?.alpha = 0.0
                        cell.movieImageView?.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.movieImageView?.alpha = 1.0
                        })
                    }
                    else
                    {
                        //print("Image was cached, just update the image.")
                        cell.movieImageView?.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.movieImageView?.image = nil
            })
        }
        cell.movieTitleLabel?.text = movie.title
        cell.movieOverviewLabel?.text = movie.overview
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let movieDetailVC = segue.destination as? MovieDetailViewController,
            let indexPath = moviesTableView.indexPathForSelectedRow
        {
            movieDetailVC.movie = movies[indexPath.row]
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl)
    {
        tmdbGetMovies(refreshControl: refreshControl)
    }
    
    // Create an array of Movie objects retrieved from The Movie Database.
    func tmdbGetMovies(refreshControl: UIRefreshControl? = nil)
    {
        // Build the URL and create the request.
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.Language: Constants.TMDBParameterValues.Language
        ]
        let request = NSMutableURLRequest(
            url: tmdbUrlFromParameters(methodParameters as [String : AnyObject],
                                       withPathExtension: pathExtension))
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        // Display progress HUD before the request is made.
        MBProgressHUD.showAdded(to: view, animated: true)
        
        // Make the request.
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            // GUARD: Was there an error?
            guard (error == nil) else
            {
                self.requestDidSucceed(false, refreshControl: refreshControl)
                //print("There was an error with the request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else
            {
                self.requestDidSucceed(false, refreshControl: refreshControl)
                //print("The request returned a status code other than 2xx.")
                return
            }
            
            // GUARD: Was any data returned?
            guard let data = data else
            {
                self.requestDidSucceed(false, refreshControl: refreshControl)
                //print("The request did not return data.")
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]
            do
            {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }
            catch
            {
                self.requestDidSucceed(false, refreshControl: refreshControl)
                //print("Could not parse the response data as JSON: '\(data)'")
                return
            }
            
            // GUARD: Get the "results" entry out of parsedResult.
            guard let results = parsedResult[Constants.TMDBResponseKeys.Results] as? [[String:AnyObject]] else
            {
                self.requestDidSucceed(false, refreshControl: refreshControl)
                //print("Cannot find key '\(Constants.TMDBResponseKeys.Results)' in \(parsedResult)")
                return
            }
            
            // Create an array of Movie objects based on the results.
            self.movies = Movie.moviesFromResults(results)
            
            self.requestDidSucceed(true, refreshControl: refreshControl)
            
            self.performUIUpdatesOnMain
            {
                self.moviesTableView.reloadData()
            }
        })
        
        // Start the request
        task.resume()
    }
    
    func tmdbUrlFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL
    {
        var components = URLComponents()
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters
        {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    // Show or hide the error banner based on success or failure. Hide the
    // progress HUD. If the optional refreshControl parameter is specified,
    // tell it to stop spinning.
    func requestDidSucceed(_ success: Bool, refreshControl: UIRefreshControl?)
    {
        performUIUpdatesOnMain
        {
            self.errorBannerView.isHidden = success
        
            MBProgressHUD.hide(for: self.view, animated: true)

            if let refreshControl = refreshControl
            {
                refreshControl.endRefreshing()
            }
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void)
    {
        DispatchQueue.main.async
        {
            updates()
        }
    }
}

