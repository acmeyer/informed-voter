# Informed Voter

An app for finding your and your friends polling stations and sharing them via iMessage.

This app is no longer maintained or on the App Store so it was open sourced.

## How to Use

1. Fork the repository
2. Install/Set up [CocoaPods](https://cocoapods.org)
3. Install [Fabric](https://fabric.io)
4. Run `pod install` in the project's root directory
5. Update `Constants.swift` file with you personal credentials
6. Add sticker images
7. Run the app

In order to get correct polling station information for an election, you'll have to look up the election's id for [Google's Civic Information API](https://developers.google.com/civic-information/docs/v2/elections/electionQuery). Note that the API is usually pretty sparse until only a few weeks before an election so you may want to use the test election info until then.

## Services Used
* Google's Civic Information API
* Google Places API
* Google Maps API
* OneSignal

## License

Released under the MIT License. See [LICENSE](LICENSE) or http://opensource.org/licenses/MIT for more information.