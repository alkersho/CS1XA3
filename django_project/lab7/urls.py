from django.urls import path
from . import views

app_name = 'lab7'

urlpatterns = [
    path('', views.lab7, name='lab7'),
]
