from django.urls import path
from . import views


app_name = 'forum'

urlpatterns = [
    path('', views.main),
    path('view/<id>/', views.view_post),
    path('create/', views.create_post),
    path('edit/<id>/', views.edit_posts),
]
