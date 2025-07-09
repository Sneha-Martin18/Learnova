from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt
import jwt
from django.conf import settings
from .models import CustomUser, AdminHOD, Staffs, Students
from .serializers import (
    CustomUserSerializer, AdminHODSerializer, StaffsSerializer, 
    StudentsSerializer, UserLoginSerializer, UserCreateSerializer
)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """User login endpoint"""
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        try:
            user = CustomUser.objects.get(email=email)
            if user.check_password(password):
                # Generate JWT token
                payload = {
                    'user_id': user.id,
                    'user_type': user.user_type,
                    'email': user.email,
                    'username': user.username
                }
                token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
                
                return Response({
                    'token': token,
                    'user': CustomUserSerializer(user).data,
                    'message': 'Login successful'
                })
            else:
                return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def user_list(request):
    """Get all users"""
    users = CustomUser.objects.all()
    serializer = CustomUserSerializer(users, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def user_detail(request, user_id):
    """Get specific user details"""
    try:
        user = CustomUser.objects.get(id=user_id)
        serializer = CustomUserSerializer(user)
        return Response(serializer.data)
    except CustomUser.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([AllowAny])
def create_user(request):
    """Create new user"""
    serializer = UserCreateSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response(CustomUserSerializer(user).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def user_profile(request):
    """Get current user profile"""
    # This would typically get user from JWT token
    # For now, we'll use a simple approach
    user_id = request.data.get('user_id')
    if user_id:
        try:
            user = CustomUser.objects.get(id=user_id)
            serializer = CustomUserSerializer(user)
            return Response(serializer.data)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response({'error': 'User ID required'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def validate_user(request):
    """Validate user token"""
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if token:
        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
            user_id = payload.get('user_id')
            user = CustomUser.objects.get(id=user_id)
            return Response({
                'valid': True,
                'user': CustomUserSerializer(user).data
            })
        except (jwt.InvalidTokenError, CustomUser.DoesNotExist):
            return Response({'valid': False}, status=status.HTTP_401_UNAUTHORIZED)
    
    return Response({'valid': False}, status=status.HTTP_401_UNAUTHORIZED)

# Health check endpoint
@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'healthy',
        'service': 'user_service',
        'message': 'User service is running'
    }) 