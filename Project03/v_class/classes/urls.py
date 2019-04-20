from django.urls import path, re_path
from . import views


app_name = 'classes'

urlpatterns = [
    path('', views.main, name='main'),
    re_path(r'^(P?<class_name>[-/w]+)/$', views.cl),
    path('announcements/', views.announcements, name='all_announcements'),
    path('classes/', views.classes)
]
