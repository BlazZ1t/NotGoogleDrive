# This is a brief introduction into the API

## Auth endpoints
### Register
Accepts two fields in its body: username and password
Username can consist of any characters as well as password
Returns nothing

### Login
Accepts two fields in its body: username and password
Returns an access token that is active for 30 minutes. Add this token to any other request header like this:
GET /list
Authorization: Bearer <token\>

## File manipulation methods
All of these methods require heaving a valid Bearer token
### Upload
Uploads a file into a user's bucket.
The body should be a file. For now let's think that any file names are acceptable. 
File name can also be a path like folder1/examplefile.txt
This will create a file folder

### List
Lists names of the user's files.
Accepts an optional prefix that will allow to search a folder with this exact prefix. If none given, will just show contents of the root directory
Returns a list of names (will add file sizes and some metadata in the future, maybe)

### Download
Downloads a file by its full name (path through folders included AND necessary)

### Delete
Deletes a file by its full name (path through folders included AND necessary)
