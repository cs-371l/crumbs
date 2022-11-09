# Crumbs Beta Release

## Contributions: 
### Amog Iska (ai5895) - 20%
- User page base views (segmented control, about segment, name and biography).
- Edit user profile view controller.
- Views (backend and frontend) for posts.
- Sorting feed chronologically (added where query)
- User karma
### Tristan Blake (tab3822) - 30%
- Sign up email validation feature on sign up view controller
- Authentication of user and sign-in/sign-out view controllers
- Sign-up view controller
- Settings view controller
- Delete account + logout on the frontend and backend
- Initial Firebase setup for posts and users
- Add Comments Page and support in Firebase for comments
- Support location in app
- Code reviews
### Kevin Li (kal3558) - 30%
- Log-in view controller
- Home tab bar navigation for view controller
- Discover and follow feed UI (table view and cell designs)
- Post view page UI (table view and cell designs)
- Liking posts implementation (Firebase modeling and UI)
- Linking profile on post view to profile view controller with filtered posts
- Image upload UI and Firebase Storage support
- Comments table view cell
- Comments upvotes and downvotes UI
- Pull to refresh to update posts in feed
- Code reviews
### Philo Lin (pl9956) - 20%
- Post Creation Page
- Following posts implementation
- Dark mode + saving user defaults

## Deviations:

We missed the following target features due to the fact that more critical features in our app took longer than expected, so we weren't able to
prioritize the following:
- Loading screen
- 3rd party authentication
- Last active/login


We were not able to complete the change username feature because this required a significant database modification (since we store a more lightweight
user model in other documents). So in order to avoid data consistency issues (i.e, a user changing their username and having the change appear in some
places but not others), we decided to defer the username change to a later release.
