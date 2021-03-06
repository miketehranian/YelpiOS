# Project 2 - *Yelp*

**Yelp** is a Yelp search app using the [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api).

Time spent: **15** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height.
   - [x] Custom cells should have the proper Auto Layout constraints.
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [x] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), distance, deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] You can use the default UISwitch for on/off states.
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [x] Display some of the available Yelp categories (choose any 3-4 that you want).

The following **optional** features are implemented:

- [x] Search results page
   - [x] Infinite scroll for restaurant results.
   - [x] Implement map view of restaurant results.
- [ ] Filter page
   - [ ] Implement a custom switch instead of the default UISwitch.
   - [ ] Distance filter should expand as in the real Yelp app
   - [ ] Categories should show a subset of the full list with a "See All" row to expand. Category list is [here](http://www.yelp.com/developers/documentation/category_list).
- [ ] Implement the restaurant detail page.

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. I would like to see if anyone implemented the details page and if they were able to embed a map nicely into the details page similar to how the Yelp details page appears. Also, I would like to learn how to implement the pull to photo gallery feature in the details page.
2. I would like to learn how to implement the accordion style dropdown for the filter categories as I didn't have time to implement that.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/NNTEtHS.gif' title='Video Walkthrough 1' width='' alt='Video Walkthrough 1' />
<img src='http://i.imgur.com/SZnsu3M.gif' title='Video Walkthrough 2' width='' alt='Video Walkthrough 2' />
<img src='http://i.imgur.com/EZRXGST.gif' title='Video Walkthrough 3' width='' alt='Video Walkthrough 3' />
<img src='http://i.imgur.com/uCTmtKX.gif' title='Video Walkthrough 4' width='' alt='Video Walkthrough 4' />
<img src='http://i.imgur.com/L2ltySQ.gif' title='Video Walkthrough 5' width='' alt='Video Walkthrough 5' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

I spent almost three hours on getting infinite scrolling working because it required learning more about the Yelp API and also testing the behavior under all use cases and fixing a few bugs. The use cases I tested heavily were navigating to the Filters and Maps View and back and making sure all of the filters were in place and infinite scrolling still worked. I tried to make my logic for this as clean as possible, but I hope I can get some insight from others to see if there was a clean way of doing this.
Also, I learned to try to avoid property observers on collections like arrays and dictionaries. Some operations which are mutating will call the property observer and others will not. I read in a blog post how this behavior was changed with the recent release of Swift. So I recommend avoiding property observers on collections because they can be nebulous as to when they actually run beyond the obvious use case of assignment.

## License

    Copyright [2016] [Mike Tehranian]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.