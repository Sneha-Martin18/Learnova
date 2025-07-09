from django.urls import path
from . import views

urlpatterns = [
    path('auth/login/', views.login_view, name='login'),
    path('auth/validate/', views.validate_user, name='validate_user'),
    path('users/', views.user_list, name='user_list'),
    path('users/<int:user_id>/', views.user_detail, name='user_detail'),
    path('users/create/', views.create_user, name='create_user'),
    path('users/profile/', views.user_profile, name='user_profile'),
    path('health/', views.health_check, name='health_check'),
] 