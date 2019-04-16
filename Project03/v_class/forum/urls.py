from django.urls import path, re_path
from . import views


app_name = 'forum'

urlpatterns = [
    path('', views.main),
    re_path(r'^(?P<post_id>\d+)/$', views.view_post),
    path('create/', views.create_post),
    re_path(r'^edit/(?P<post_id>\d+)/$', views.edit_posts),
]
