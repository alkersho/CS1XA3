from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('account/', include('people.urls')),
    path('forum/', include('forum.urls')),
    path('class/', include('classes.urls')),
]
