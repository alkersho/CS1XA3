# Project 03 - Online Forum
---
## General Information
This is an online forum. Nothing special about it. You can post and comment, and the admin can be a tyrant if they wish.
Built using django 2.2 and elm. All elm packages are listed in elm.json.

## Installation and Usage
> Important Note: This project uses python3 and may not work with older versions.
1. Create a [python virtual environment](https://docs.python.org/3/library/venv.html). (The location of the virtual environment in arbitiary). A [quick guide](https://uoa-eresearch.github.io/eresearch-cookbook/recipe/2014/11/26/python-virtual-env/) on how to create a virtual environment.
2. Activate the Pyvenv(Python Virtual Environment): `source /path/to/venv/bin/activate`.
3. Install the required packages using pip from `CS1XA3/Project03/requirements.txt` using the command `pip install -r requirements.txt`. Make sure it is using python3 using `pip --version`.
4. Go to the django project to directory, `v_class`.
5. Make sure that everything is done properly by running `python3 manage.py shell`. If it is, you will find yourself in a python shell. Otherwise go back and fix it.
6. Run the following commands:
    a. `python3 manage.py makemigrations`
    b. `python3 manage.py migrate`
    c. `python3 manage.py runserver localhost:10003`(The port is only required for the mac1xa3.ca server, otherwise there is no need to specify the port, the bit after the ':').
7. Open your browser and visit `localhost:10003/e/alkersho/forum/`. This should get you to the front page.
8. From here you can create accounts and create posts, provided you are logged in. 
> The first account created gets admin and superuser priviliges, so remember it very well.

### Admin User
The super user is capable of:
* Adding/deleting Topics
* Changing user types, from user to admin and vie versa
To access the admin page click on the account name in the nav bar, next to logout, then click on admin.
> The admin user is also a django super user, so accessing `/e/alkersho/admin/` will allow the user to edit and change data in the app such as posts and comments

### General Usage
The rest is very simple and is not worthy of their own sections, so they are summed in the bullet points:
* You can create posts using the button on the main forum page
* You can edit the body of your post
* Posts support markdown language, but not comments
* You can reply to ther comments, but you need to refresh the page after doing so due to a bug, “¯\\\_(ツ)_/¯“
