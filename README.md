# AIImageCompare

AIImageCompare is a library of image comparison algorithms. It is most useful when dealing with images that may be very similar but not exactly the same. For instance for `UIView` unit tests.

The project is in an early development stage. The only implemented function is to calculate the [mean absolute error](http://en.wikipedia.org/wiki/Mean_absolute_error) between two  images.

## Usage
Add AIImageCompate.[h,m] to your project or add `pod 'AIImageCompare'` to your Podfile.
