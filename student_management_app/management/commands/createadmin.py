from django.core.management.base import BaseCommand
from student_management_app.models import CustomUser, AdminHOD


class Command(BaseCommand):
    help = 'Creates an admin user with email admin@gmail.com and password admin'

    def handle(self, *args, **kwargs):
        try:
            # Check if admin already exists
            existing_user = CustomUser.objects.filter(email="admin@gmail.com").first()
            if existing_user:
                self.stdout.write(self.style.WARNING('Admin user already exists. Updating password...'))
                existing_user.set_password("admin")
                existing_user.save()
                self.stdout.write(self.style.SUCCESS('Password updated successfully!'))
                self.stdout.write(f'Email: admin@gmail.com')
                self.stdout.write(f'Password: admin')
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
            
            self.stdout.write(self.style.SUCCESS('Admin user created successfully!'))
            self.stdout.write(f'Email: admin@gmail.com')
            self.stdout.write(f'Password: admin')
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Error creating admin: {str(e)}'))
            import traceback
            traceback.print_exc()
