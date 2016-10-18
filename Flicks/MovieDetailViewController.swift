//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Dylan Miller on 10/16/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController
{
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieInfoView: UIView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var movie: Movie?
    var tabBarWasHidden = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let movie = movie
        {
            if let posterSmallImageUrl = movie.posterSmallImageUrl
            {
                // Load the low-res image first and switch to high-res when complete.
                let smallImageRequest = URLRequest(url: posterSmallImageUrl)
                movieImageView.setImageWith(
                    smallImageRequest,
                    placeholderImage: nil,
                    success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                        
                        // Fade in the small image.
                        self.movieImageView.alpha = 0.0
                        self.movieImageView.image = smallImage
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            
                            self.movieImageView.alpha = 1.0
                            
                            }, completion: { (success) -> Void in
                                
                                // The AFNetworking ImageView Category only
                                // allows one request to be sent at a time
                                // per ImageView, so this code must be in the
                                // completion block.
                                self.setLargeImage(smallImage: smallImage)
                        })
                    },
                    failure: { (imageRequest, imageResponse, error) -> Void in
                        self.movieImageView.image = nil
                })
            }
            movieTitleLabel.text = movie.title
            movieOverviewLabel.text = movie.overview
        }
        
        scrollView.contentSize = CGSize(width: scrollView.superview!.frame.size.width, height: movieInfoView.frame.origin.y + movieInfoView.frame.size.height)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Hide tab bar.
        if let tabBarController = tabBarController
        {
            tabBarWasHidden = tabBarController.tabBar.isHidden
            tabBarController.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Un-hide the tab bar.
        if let tabBarController = tabBarController
        {
            tabBarController.tabBar.isHidden = tabBarWasHidden
        }
    }
    
    // Set the poster image to the posterLargeImageUrl image.
    func setLargeImage(smallImage: UIImage)
    {
        if let movie = movie,
            let posterLargeImageUrl = movie.posterLargeImageUrl
        {
            let largeImageRequest = URLRequest(url: posterLargeImageUrl)
            movieImageView.setImageWith(
                largeImageRequest,
                placeholderImage: smallImage,
                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                    
                    self.movieImageView.image = largeImage;
                    
                },
                failure: { (request, response, error) -> Void in
                    
                    self.movieImageView.image = nil
                    
            })
        }
    }
}
