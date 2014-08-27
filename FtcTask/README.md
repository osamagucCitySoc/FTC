Hello FTC, it was my pleasure completing this challenging task.

The application includes good level of inline documentation, the commits's comments shows how the development of pieces took turn to build the final project and moreover included an activity diagram that shows the execution flow to make it crystal clear for your review.

The app in a nutshell works as follows:
  1.- Upon starting it shows titles and messages depending on the last chosen language by the user (default is english).
  
  2- Then it checks for internet connection:
    2.1- If we are offline, then we render nothing infront of the user and other parts are accessible.
    2.2 If we are online, then go to step 3.
  3- Show a loader view and prevent interaction.
  4- Contact flickr with my registered app token api to get the last images posted with tag "it".
  5- Upon getting the result from flickr:
    5.1 - If there is an error from flickr (overloaded, down, etc etc) then we show an error message.
    5.2 - If the data is valid, we parse it and because it is first time we are allowed to insert all data at once and reload data for table view and collection view.
  6- Then all images are shown as "ORANGE" rectangle until images being loaded from flickr.
  7- Every image upon loading, it stores itself into the cache (so whenever you scrollback to it, it is loaded in a glance directly from cache).
  8- User can flip back and forth between collection view and table from the upper right button.
  9- User can pull to refresh:
    9.1 - Loader is being shown.
    9.2 - Asks flickr to return us images that ONLY being uploaded after our last query.
    9.3 - Parse photos if any.
    9.4 - And because we are not allowed to use reloadData and because we cannot update more than 31 item at the same time for the ui collection view, a trick had been added which is the updates are being done in groups of 20. Never start for the next 20 until the first 20 finishes. So we get the items updated with a nice animation and they are synchronized in groups of 20 to prevent errors and crashes.
  10 - User clicks on settings:
    10.1 avaliable options (english and germany).
    10.2 The already chosen language is being highlted (english by default).
    10.3 upon choosing language, all the app changes without restarting.
  11. If the user clicks on an image, it shows in full screen with pinch zooming.
  12. 
  
General Notes:
  1. To support specific orientation modes in every screen is not possible in iOS 7 without customizing the uinavigationcontroller. (DONE).
  2. Cannot update more than 31 item at the same time for collection view. (Done by synchronizing the changes in groups of 20 flow after each other).
  3. Added the code for face detection in the images but commented out. Because it is not adequate to detect faces for 100 images with scrolling. It is just there as a proof of ability.