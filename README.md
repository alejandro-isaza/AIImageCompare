# AIImageCompare

AIImageCompare is a library of image comparison algorithms. It is most useful when dealing with images that may be very similar but not exactly the same. For instance for `UIView` unit tests.

Right now it provides a few error functions:
* [Mean absolute error](http://en.wikipedia.org/wiki/Mean_absolute_error)
* [Root mean square error](http://en.wikipedia.org/wiki/Root-mean-square_deviation)
* Different pixel count
* Different pixel ratio (percentage)

## Usage
Add AIImageCompate.[h,m] to your project or add `pod 'AIImageCompare', '~> 0.1.2'` to your Podfile.
