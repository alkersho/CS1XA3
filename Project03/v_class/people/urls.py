from django.urls import path
from . import views


app_name = 'people'

urlpatterns = [
    path('', views.main, name="account"),
    path('login/', views.login_page, name="login"),
    path('register/', views.register, name="register"),
    path('logout/', views.logout_page, name="logout")
]
