# NSURLCache Testharness

Is `NSURLCache` broken in iOS8.1 ?

I created this simple test project to show that my `NSURLCache` does not work as I would expect. Take a look and let me know what I did wrong! The ever so slightest hint is very welcome! Thanks!

## The App Interface
![The app interface](https://github.com/opfeffer/nsurlcache/raw/master/screenshot.png)

* Top section hosts six `UIImageView` instances.
* Middle section shows information about the current state of our `NSURLCache` instance.
* The table view shows the logs broken out on a per-request-level.