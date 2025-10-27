import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'student_management_system.settings')
django.setup()

from student_management_app.models import CustomUser, AdminHOD

def create_admin():
    try:
        # Check if admin already exists
        existing_admin = CustomUser.objects.filter(email="admin@gmail.com").first()
        if existing_admin:
            print("Admin user already exists!")
            print("Email: admin@gmail.com")
            print("Password: admin@123")
            return
        
        # Create custom user with user_type as string "1" (for HOD/Admin)
        user = CustomUser.objects.create_user(
            username="admin",
            email="admin@gmail.com",
            password="admin@123",
            user_type="1",  # "1" for HOD/Admin (as string)
            first_name="System",
            last_name="Admin"
        )
        
        # Create AdminHOD profile (required for admin dashboard access)
        admin_hod = AdminHOD.objects.create(
            admin=user
        )
        
        print("✓ Admin user created successfully!")
        print("✓ AdminHOD profile created!")
        print("Email: admin@gmail.com")
        print("Password: admin@123")
        print("User Type: 1 (HOD/Admin)")
        
    except Exception as e:
        print(f"✗ Error creating admin: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_admin()
