from django.urls import path
from . import views


app_label = 'people'

urlpatterns = [
    path('', views.main),
    path('login/', views.login),
    path('register/', views.register),
]
