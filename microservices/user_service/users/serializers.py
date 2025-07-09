from rest_framework import serializers
from .models import CustomUser, AdminHOD, Staffs, Students

class CustomUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'user_type', 'is_active']
        read_only_fields = ['id']

class AdminHODSerializer(serializers.ModelSerializer):
    admin = CustomUserSerializer(read_only=True)
    
    class Meta:
        model = AdminHOD
        fields = ['id', 'admin', 'created_at', 'updated_at']

class StaffsSerializer(serializers.ModelSerializer):
    admin = CustomUserSerializer(read_only=True)
    
    class Meta:
        model = Staffs
        fields = ['id', 'admin', 'address', 'created_at', 'updated_at']

class StudentsSerializer(serializers.ModelSerializer):
    admin = CustomUserSerializer(read_only=True)
    
    class Meta:
        model = Students
        fields = ['id', 'admin', 'gender', 'profile_pic', 'address', 'course_id', 'session_year_id', 'created_at', 'updated_at']

class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password', 'first_name', 'last_name', 'user_type']
    
    def create(self, validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user 