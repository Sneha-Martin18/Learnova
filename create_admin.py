import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'student_management_system.settings')
django.setup()

from student_management_app.models import CustomUser, AdminHOD

def create_admin():
    try:
        # Check if admin already exists
        existing_user = CustomUser.objects.filter(email="admin@gmail.com").first()
        if existing_user:
            print("Admin user already exists. Updating password...")
            existing_user.set_password("admin")
            existing_user.save()
            print("Password updated successfully!")
            print("Email: admin@gmail.com")
            print("Password: admin")
            return
        
        # Create custom user
        user = CustomUser.objects.create_user(
            username="admin",
            email="admin@gmail.com",
            password="admin",
            user_type="1",  # 1 for admin/HOD
            first_name="System",
            last_name="Admin"
        )
        
        # Create admin profile
        admin = AdminHOD.objects.create(
            admin=user
        )
        
        print("Admin user created successfully!")
        print("Email: admin@gmail.com")
        print("Password: admin")
        
    except Exception as e:
        print(f"Error creating admin: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_admin()
