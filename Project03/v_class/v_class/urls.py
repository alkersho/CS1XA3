from django.contrib import admin
from django.urls import path, include

# changed later to fit server
root = "e/alkersho/"

urlpatterns = [
    path(root + 'admin/', admin.site.urls),
    path(root + 'account/', include('people.urls')),
    path(root + 'forum/', include('forum.urls')),
    path(root + 'class/', include('classes.urls')),
]
