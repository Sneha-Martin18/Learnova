import jwt
from django.conf import settings
from django.http import JsonResponse
from functools import wraps
import requests

def generate_jwt_token(user_data):
    """Generate JWT token for user"""
    payload = {
        'user_id': user_data.get('id'),
        'user_type': user_data.get('user_type'),
        'email': user_data.get('email'),
        'username': user_data.get('username')
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')

def verify_jwt_token(token):
    """Verify JWT token and return payload"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        return payload
    except jwt.InvalidTokenError:
        return None

def jwt_required(view_func):
    """Decorator to require JWT authentication"""
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token:
            return JsonResponse({'error': 'No token provided'}, status=401)
        
        payload = verify_jwt_token(token)
        if not payload:
            return JsonResponse({'error': 'Invalid token'}, status=401)
        
        request.user_info = payload
        return view_func(request, *args, **kwargs)
    return wrapper

def get_user_info(user_id):
    """Get user information from User Service"""
    try:
        response = requests.get(f'http://user-service:8001/api/users/{user_id}/')
        if response.status_code == 200:
            return response.json()
        return None
    except requests.RequestException:
        return None 