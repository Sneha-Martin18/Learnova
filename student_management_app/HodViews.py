import json

from django.contrib import messages
from django.core import serializers
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

from student_management_app.models import (Attendance, AttendanceReport,
                                           Courses, CustomUser, FeedBackStaffs,
                                           FeedBackStudent, LeaveReportStaff,
                                           LeaveReportStudent,
                                           SessionYearModel, Staffs, Students,
                                           Subjects)

from .forms import AddStudentForm, EditStudentForm


def admin_home(request):
    all_student_count = Students.objects.all().count()
    subject_count = Subjects.objects.all().count()
    course_count = Courses.objects.all().count()
    staff_count = Staffs.objects.all().count()

    # Total Subjects and students in Each Course
    course_all = Courses.objects.all()
    course_name_list = []
    subject_count_list = []
    student_count_list_in_course = []

    for course in course_all:
        subjects = Subjects.objects.filter(course_id=course.id).count()
        students = Students.objects.filter(course_id=course.id).count()
        course_name_list.append(course.course_name)
        subject_count_list.append(subjects)
        student_count_list_in_course.append(students)

    subject_all = Subjects.objects.all()
    subject_list = []
    student_count_list_in_subject = []
    for subject in subject_all:
        course = Courses.objects.get(id=subject.course_id.id)
        student_count = Students.objects.filter(course_id=course.id).count()
        subject_list.append(subject.subject_name)
        student_count_list_in_subject.append(student_count)

    # For Saffs
    staff_attendance_present_list = []
    staff_attendance_leave_list = []
    staff_name_list = []

    staffs = Staffs.objects.all()
    for staff in staffs:
        subject_ids = Subjects.objects.filter(staff_id=staff.admin.id)
        attendance = Attendance.objects.filter(subject_id__in=subject_ids).count()
        leaves = LeaveReportStaff.objects.filter(
            staff_id=staff.id, leave_status=1
        ).count()
        staff_attendance_present_list.append(attendance)
        staff_attendance_leave_list.append(leaves)
        staff_name_list.append(staff.admin.first_name)

    # For Students
    student_attendance_present_list = []
    student_attendance_leave_list = []
    student_name_list = []

    students = Students.objects.all()
    for student in students:
        attendance = AttendanceReport.objects.filter(
            student_id=student.id, status=True
        ).count()
        absent = AttendanceReport.objects.filter(
            student_id=student.id, status=False
        ).count()
        leaves = LeaveReportStudent.objects.filter(
            student_id=student.id, leave_status=1
        ).count()
        student_attendance_present_list.append(attendance)
        student_attendance_leave_list.append(leaves + absent)
        student_name_list.append(student.admin.first_name)

    context = {
        "all_student_count": all_student_count,
        "subject_count": subject_count,
        "course_count": course_count,
        "staff_count": staff_count,
        "course_name_list": course_name_list,
        "subject_count_list": subject_count_list,
        "student_count_list_in_course": student_count_list_in_course,
        "subject_list": subject_list,
        "student_count_list_in_subject": student_count_list_in_subject,
        "staff_attendance_present_list": staff_attendance_present_list,
        "staff_attendance_leave_list": staff_attendance_leave_list,
        "staff_name_list": staff_name_list,
        "student_attendance_present_list": student_attendance_present_list,
        "student_attendance_leave_list": student_attendance_leave_list,
        "student_name_list": student_name_list,
    }
    return render(request, "hod_template/home_content.html", context)


def add_staff(request):
    return render(request, "hod_template/add_staff_template.html")


def add_staff_save(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method ")
        return redirect("add_staff")
    else:
        first_name = request.POST.get("first_name")
        last_name = request.POST.get("last_name")
        username = request.POST.get("username")
        email = request.POST.get("email")
        password = request.POST.get("password")
        address = request.POST.get("address")

        try:
            user = CustomUser.objects.create_user(
                username=username,
                password=password,
                email=email,
                first_name=first_name,
                last_name=last_name,
                user_type=2,
            )
            user.staffs.address = address
            user.save()
            messages.success(request, "Staff Added Successfully!")
            return redirect("add_staff")
        except:
            messages.error(request, "Failed to Add Staff!")
            return redirect("add_staff")


def manage_staff(request):
    # Get all staff users
    staff_users = CustomUser.objects.filter(user_type=2).order_by("-id")
    staffs_dict = {}

    # Get all existing staff profiles
    staffs = Staffs.objects.select_related("admin").all()
    for staff in staffs:
        staffs_dict[staff.admin.id] = staff

    # Create a list of staff data, including users without profiles
    staff_data = []
    from student_management_app.models import Subjects

    for user in staff_users:
        subjects_qs = Subjects.objects.filter(staff_id=user.id)
        subjects = list(subjects_qs.values_list("subject_name", flat=True))
        data = {
            "id": user.id,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "username": user.username,
            "has_profile": False,
            "profile": None,
            "subjects": subjects,
        }
        if user.id in staffs_dict:
            data["has_profile"] = True
            data["profile"] = staffs_dict[user.id]
        staff_data.append(data)

    context = {"staff_data": staff_data}
    return render(request, "hod_template/manage_staff_template.html", context)


def edit_staff(request, staff_id):
    staff = Staffs.objects.get(admin=staff_id)

    context = {"staff": staff, "id": staff_id}
    return render(request, "hod_template/edit_staff_template.html", context)


def edit_staff_save(request):
    if request.method != "POST":
        return HttpResponse("<h2>Method Not Allowed</h2>")
    else:
        staff_id = request.POST.get("staff_id")
        username = request.POST.get("username")
        email = request.POST.get("email")
        first_name = request.POST.get("first_name")
        last_name = request.POST.get("last_name")
        address = request.POST.get("address")

        try:
            # INSERTING into Customuser Model
            user = CustomUser.objects.get(id=staff_id)
            user.first_name = first_name
            user.last_name = last_name
            user.email = email
            user.username = username
            user.save()

            # INSERTING into Staff Model
            staff_model = Staffs.objects.get(admin=staff_id)
            staff_model.address = address
            staff_model.save()

            messages.success(request, "Staff Updated Successfully.")
            return redirect("/edit_staff/" + staff_id)

        except:
            messages.error(request, "Failed to Update Staff.")
            return redirect("/edit_staff/" + staff_id)


def delete_staff(request, staff_id):
    try:
        # Resolve both the user and the staff profile
        user = CustomUser.objects.get(id=staff_id, user_type=2)
        staff = Staffs.objects.get(admin=user)

        # Clean up related data that references Staffs or the staff CustomUser
        # 1) Subjects assigned to this staff (Subjects.staff_id -> CustomUser)
        Subjects.objects.filter(staff_id=user).delete()

        # 2) Attendance for those subjects and their reports
        attendance_qs = Attendance.objects.filter(subject_id__staff_id=user)
        AttendanceReport.objects.filter(attendance_id__in=attendance_qs).delete()
        attendance_qs.delete()

        # 3) Feedback and Leave reports referencing Staffs
        FeedBackStaffs.objects.filter(staff_id=staff).delete()
        LeaveReportStaff.objects.filter(staff_id=staff).delete()

        # Finally delete Staff profile then the user
        staff.delete()
        user.delete()

        messages.success(request, "Staff Deleted Successfully.")
        return redirect("manage_staff")
    except Exception as e:
        messages.error(request, f"Failed to Delete Staff: {str(e)}")
        return redirect("manage_staff")


def delete_incomplete_staff(request, user_id):
    try:
        # Get the CustomUser object
        user = CustomUser.objects.get(id=user_id, user_type=2)

        # Check if the user has a staff profile
        try:
            staff = Staffs.objects.get(admin=user)
            messages.error(request, "Cannot delete: Staff has a complete profile")
        except Staffs.DoesNotExist:
            # Delete related records first
            try:
                # Delete any subjects assigned to this staff
                Subjects.objects.filter(staff_id=user).delete()

                # Delete any attendance records (Attendance has no direct staff FK)
                attendance_dates = Attendance.objects.filter(subject_id__staff_id=user)
                AttendanceReport.objects.filter(attendance_id__in=attendance_dates).delete()
                attendance_dates.delete()

                # Delete any feedback
                FeedBackStaffs.objects.filter(staff_id__admin=user).delete()

                # Delete any leave reports
                LeaveReportStaff.objects.filter(staff_id__admin=user).delete()

                # Finally delete the user
                user.delete()
                messages.success(
                    request, "Incomplete staff account deleted successfully!"
                )
            except Exception as e:
                messages.error(request, f"Error deleting staff: {str(e)}")

    except CustomUser.DoesNotExist:
        messages.error(request, "Staff not found")

    return redirect("manage_staff")


def add_course(request):
    return render(request, "hod_template/add_course_template.html")


def add_course_save(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method!")
        return redirect("add_course")
    else:
        course = request.POST.get("course")
        if not course:
            messages.error(request, "Course name is required!")
            return redirect("add_course")
        try:
            # Check if course already exists
            if Courses.objects.filter(course_name=course).exists():
                messages.error(request, "Course already exists!")
                return redirect("add_course")

            course_model = Courses(course_name=course)
            course_model.save()
            messages.success(request, "Course Added Successfully!")
            return redirect("add_course")
        except Exception as e:
            messages.error(request, f"Failed to Add Course: {str(e)}")
            return redirect("add_course")


def manage_course(request):
    courses = Courses.objects.all()
    context = {"courses": courses}
    return render(request, "hod_template/manage_course_template.html", context)


def edit_course(request, course_id):
    course = Courses.objects.get(id=course_id)
    context = {"course": course, "id": course_id}
    return render(request, "hod_template/edit_course_template.html", context)


def edit_course_save(request):
    if request.method != "POST":
        HttpResponse("Invalid Method")
    else:
        course_id = request.POST.get("course_id")
        course_name = request.POST.get("course")

        try:
            course = Courses.objects.get(id=course_id)
            course.course_name = course_name
            course.save()

            messages.success(request, "Course Updated Successfully.")
            return redirect("/edit_course/" + course_id)

        except:
            messages.error(request, "Failed to Update Course.")
            return redirect("/edit_course/" + course_id)


def delete_course(request, course_id):
    course = Courses.objects.get(id=course_id)
    try:
        course.delete()
        messages.success(request, "Course Deleted Successfully.")
        return redirect("manage_course")
    except:
        messages.error(request, "Failed to Delete Course.")
        return redirect("manage_course")


def manage_session(request):
    session_years = SessionYearModel.objects.all()
    context = {"session_years": session_years}
    return render(request, "hod_template/manage_session_template.html", context)


def add_session(request):
    return render(request, "hod_template/add_session_template.html")


def add_session_save(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method")
        return redirect("add_session")
    else:
        session_start_year = request.POST.get("session_start_year")
        session_end_year = request.POST.get("session_end_year")

        if not session_start_year or not session_end_year:
            messages.error(request, "Both session start and end years are required!")
            return redirect("add_session")

        try:
            # Check if session year already exists
            if SessionYearModel.objects.filter(
                session_start_year=session_start_year, session_end_year=session_end_year
            ).exists():
                messages.error(request, "Session year already exists!")
                return redirect("add_session")

            sessionyear = SessionYearModel(
                session_start_year=session_start_year, session_end_year=session_end_year
            )
            sessionyear.save()
            messages.success(request, "Session Year added Successfully!")
            return redirect("add_session")
        except Exception as e:
            messages.error(request, f"Failed to Add Session Year: {str(e)}")
            return redirect("add_session")


def edit_session(request, session_id):
    session_year = SessionYearModel.objects.get(id=session_id)
    context = {"session_year": session_year}
    return render(request, "hod_template/edit_session_template.html", context)


def edit_session_save(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method!")
        return redirect("manage_session")
    else:
        session_id = request.POST.get("session_id")
        session_start_year = request.POST.get("session_start_year")
        session_end_year = request.POST.get("session_end_year")

        try:
            session_year = SessionYearModel.objects.get(id=session_id)
            session_year.session_start_year = session_start_year
            session_year.session_end_year = session_end_year
            session_year.save()

            messages.success(request, "Session Year Updated Successfully.")
            return redirect("/edit_session/" + session_id)
        except:
            messages.error(request, "Failed to Update Session Year.")
            return redirect("/edit_session/" + session_id)


def delete_session(request, session_id):
    session = SessionYearModel.objects.get(id=session_id)
    try:
        session.delete()
        messages.success(request, "Session Deleted Successfully.")
        return redirect("manage_session")
    except:
        messages.error(request, "Failed to Delete Session.")
        return redirect("manage_session")


def add_student(request):
    form = AddStudentForm()
    context = {"form": form}
    return render(request, "hod_template/add_student_template.html", context)


def add_student_save(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method")
        return redirect("add_student")
    else:
        form = AddStudentForm(request.POST, request.FILES)

        if form.is_valid():
            first_name = form.cleaned_data["first_name"]
            last_name = form.cleaned_data["last_name"]
            username = form.cleaned_data["username"]
            email = form.cleaned_data["email"]
            password = form.cleaned_data["password"]
            address = form.cleaned_data.get("address", "")
            session_year_id = form.cleaned_data.get("session_year_id")
            course_id = form.cleaned_data.get("course_id")
            gender = form.cleaned_data.get("gender", "")

            # Check if username already exists
            if CustomUser.objects.filter(username=username).exists():
                messages.error(
                    request,
                    "Username already exists. Please choose a different username.",
                )
                return redirect("add_student")

            # Check if email already exists
            if CustomUser.objects.filter(email=email).exists():
                messages.error(
                    request, "Email already exists. Please use a different email."
                )
                return redirect("add_student")

            # Getting Profile Pic first
            if "profile_pic" in request.FILES:
                profile_pic = request.FILES["profile_pic"]
            else:
                profile_pic = None

            try:
                # Validate course and session year before creating user
                course_obj = None
                session_year_obj = None

                if course_id:
                    try:
                        course_obj = Courses.objects.get(id=int(course_id))
                    except (Courses.DoesNotExist, ValueError):
                        messages.error(
                            request, "Invalid course selected. Please try again."
                        )
                        return redirect("add_student")
                else:
                    messages.error(request, "Course is required.")
                    return redirect("add_student")

                if session_year_id:
                    try:
                        session_year_obj = SessionYearModel.objects.get(
                            id=int(session_year_id)
                        )
                    except (SessionYearModel.DoesNotExist, ValueError):
                        messages.error(
                            request, "Invalid session year selected. Please try again."
                        )
                        return redirect("add_student")
                else:
                    messages.error(request, "Session year is required.")
                    return redirect("add_student")

                # Check if a student with this email already exists
                if Students.objects.filter(admin__email=email).exists():
                    messages.error(request, "A student with this email already exists.")
                    return redirect("add_student")

                # Create user object
                user = CustomUser.objects.create_user(
                    username=username,
                    password=password,
                    email=email,
                    first_name=first_name,
                    last_name=last_name,
                    user_type=3,
                )

                try:
                    # Create student profile
                    student = Students.objects.create(
                        admin=user,
                        address=address,
                        course_id=course_obj,
                        session_year_id=session_year_obj,
                        gender=gender,
                        profile_pic=profile_pic,
                    )
                    messages.success(request, "Student Added Successfully!")
                    return redirect("manage_student")
                except Exception as e:
                    # If student profile creation fails, delete the user and show detailed error
                    user.delete()
                    print(f"Error creating student profile: {str(e)}")
                    messages.error(
                        request, f"Failed to create student profile: {str(e)}"
                    )
                    return redirect("add_student")

            except Exception as e:
                messages.error(request, f"Failed to Add Student: {str(e)}")
                return redirect("add_student")
        else:
            # If form is not valid, show form errors
            for field, errors in form.errors.items():
                for error in errors:
                    messages.error(request, f"{field}: {error}")
            return redirect("add_student")


def manage_student(request):
    # Get all student users
    student_users = CustomUser.objects.filter(user_type=3).order_by("-id")
    students_dict = {}

    # Get all existing student profiles
    students = Students.objects.select_related(
        "admin", "course_id", "session_year_id"
    ).all()
    for student in students:
        students_dict[student.admin.id] = student

    # Create a list of student data, including users without profiles
    student_data = []
    for user in student_users:
        data = {
            "id": user.id,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "username": user.username,
            "has_profile": False,
            "profile": None,
        }
        if user.id in students_dict:
            data["has_profile"] = True
            data["profile"] = students_dict[user.id]
        student_data.append(data)

    context = {"student_data": student_data}
    return render(request, "hod_template/manage_student_template.html", context)


def edit_student(request, student_id):
    # Adding Student ID into Session Variable
    request.session["student_id"] = student_id

    student = Students.objects.get(admin=student_id)
    form = EditStudentForm()
    # Filling the form with Data from Database
    form.fields["email"].initial = student.admin.email
    form.fields["username"].initial = student.admin.username
    form.fields["first_name"].initial = student.admin.first_name
    form.fields["last_name"].initial = student.admin.last_name
    form.fields["address"].initial = student.address
    form.fields["course_id"].initial = student.course_id.id
    form.fields["gender"].initial = student.gender
    form.fields["session_year_id"].initial = student.session_year_id.id

    context = {"id": student_id, "username": student.admin.username, "form": form}
    return render(request, "hod_template/edit_student_template.html", context)


def edit_student_save(request):
    if request.method != "POST":
        return HttpResponse("Invalid Method!")
    else:
        student_id = request.session.get("student_id")
        if student_id == None:
            return redirect("/manage_student")

        form = EditStudentForm(request.POST, request.FILES)
        if form.is_valid():
            email = form.cleaned_data["email"]
            username = form.cleaned_data["username"]
            first_name = form.cleaned_data["first_name"]
            last_name = form.cleaned_data["last_name"]
            address = form.cleaned_data["address"]
            course_id = form.cleaned_data["course_id"]
            gender = form.cleaned_data["gender"]
            session_year_id = form.cleaned_data["session_year_id"]

            # Getting Profile Pic first
            # First Check whether the file is selected or not
            # Upload only if file is selected
            if len(request.FILES) != 0:
                profile_pic = request.FILES["profile_pic"]
                fs = FileSystemStorage()
                filename = fs.save(profile_pic.name, profile_pic)
                profile_pic_url = fs.url(filename)
            else:
                profile_pic_url = None

            try:
                # First Update into Custom User Model
                user = CustomUser.objects.get(id=student_id)
                user.first_name = first_name
                user.last_name = last_name
                user.email = email
                user.username = username
                user.save()

                # Then Update Students Table
                student_model = Students.objects.get(admin=student_id)
                student_model.address = address

                course = Courses.objects.get(id=course_id)
                student_model.course_id = course

                session_year_obj = SessionYearModel.objects.get(id=session_year_id)
                student_model.session_year_id = session_year_obj

                student_model.gender = gender
                if profile_pic_url != None:
                    student_model.profile_pic = profile_pic_url
                student_model.save()
                # Delete student_id SESSION after the data is updated
                del request.session["student_id"]

                messages.success(request, "Student Updated Successfully!")
                return redirect("/edit_student/" + student_id)
            except:
                messages.success(request, "Failed to Uupdate Student.")
                return redirect("/edit_student/" + student_id)
        else:
            return redirect("/edit_student/" + student_id)


def delete_student(request, student_id):
    student = Students.objects.get(admin=student_id)
    try:
        student.delete()
        messages.success(request, "Student Deleted Successfully.")
        return redirect("manage_student")
    except:
        messages.error(request, "Failed to Delete Student.")
        return redirect("manage_student")


def delete_incomplete_student(request, user_id):
    try:
        # Get the CustomUser object
        user = CustomUser.objects.get(id=user_id, user_type=3)

        # Check if the user has a student profile
        try:
            student = Students.objects.get(admin=user)
            messages.error(request, "Cannot delete: Student has a complete profile")
        except Students.DoesNotExist:
            # Only delete if there's no student profile
            user.delete()
            messages.success(
                request, "Incomplete student account deleted successfully!"
            )

    except CustomUser.DoesNotExist:
        messages.error(request, "Student not found")

    return redirect("manage_student")


def add_subject(request):
    courses = Courses.objects.all()
    staffs = CustomUser.objects.filter(user_type="2")
    context = {"courses": courses, "staffs": staffs}
    return render(request, "hod_template/add_subject_template.html", context)


def add_subject_save(request):
    if request.method != "POST":
        messages.error(request, "Method Not Allowed!")
        return redirect("add_subject")
    else:
        subject_name = request.POST.get("subject")

        course_id = request.POST.get("course")
        course = Courses.objects.get(id=course_id)

        staff_id = request.POST.get("staff")
        staff = CustomUser.objects.get(id=staff_id)

        try:
            subject = Subjects(
                subject_name=subject_name, course_id=course, staff_id=staff
            )
            subject.save()
            messages.success(request, "Subject Added Successfully!")
            return redirect("add_subject")
        except:
            messages.error(request, "Failed to Add Subject!")
            return redirect("add_subject")


def manage_subject(request):
    subjects = Subjects.objects.all()
    context = {"subjects": subjects}
    return render(request, "hod_template/manage_subject_template.html", context)


def edit_subject(request, subject_id):
    subject = Subjects.objects.get(id=subject_id)
    courses = Courses.objects.all()
    staffs = CustomUser.objects.filter(user_type="2")
    context = {
        "subject": subject,
        "courses": courses,
        "staffs": staffs,
        "id": subject_id,
    }
    return render(request, "hod_template/edit_subject_template.html", context)


def edit_subject_save(request):
    if request.method != "POST":
        HttpResponse("Invalid Method.")
    else:
        subject_id = request.POST.get("subject_id")
        subject_name = request.POST.get("subject")
        course_id = request.POST.get("course")
        staff_id = request.POST.get("staff")

        try:
            subject = Subjects.objects.get(id=subject_id)
            subject.subject_name = subject_name

            course = Courses.objects.get(id=course_id)
            subject.course_id = course

            staff = CustomUser.objects.get(id=staff_id)
            subject.staff_id = staff

            subject.save()

            messages.success(request, "Subject Updated Successfully.")
            # return redirect('/edit_subject/'+subject_id)
            return HttpResponseRedirect(
                reverse("edit_subject", kwargs={"subject_id": subject_id})
            )

        except:
            messages.error(request, "Failed to Update Subject.")
            return HttpResponseRedirect(
                reverse("edit_subject", kwargs={"subject_id": subject_id})
            )
            # return redirect('/edit_subject/'+subject_id)


def delete_subject(request, subject_id):
    subject = Subjects.objects.get(id=subject_id)
    try:
        subject.delete()
        messages.success(request, "Subject Deleted Successfully.")
        return redirect("manage_subject")
    except:
        messages.error(request, "Failed to Delete Subject.")
        return redirect("manage_subject")


@csrf_exempt
def check_email_exist(request):
    email = request.POST.get("email")
    user_obj = CustomUser.objects.filter(email=email).exists()
    if user_obj:
        return HttpResponse(True)
    else:
        return HttpResponse(False)


@csrf_exempt
def check_username_exist(request):
    username = request.POST.get("username")
    user_obj = CustomUser.objects.filter(username=username).exists()
    if user_obj:
        return HttpResponse(True)
    else:
        return HttpResponse(False)


def student_feedback_message(request):
    feedbacks = FeedBackStudent.objects.all()
    context = {"feedbacks": feedbacks}
    return render(request, "hod_template/student_feedback_template.html", context)


@csrf_exempt
def student_feedback_message_reply(request):
    feedback_id = request.POST.get("id")
    feedback_reply = request.POST.get("reply")

    try:
        feedback = FeedBackStudent.objects.get(id=feedback_id)
        feedback.feedback_reply = feedback_reply
        feedback.save()
        return HttpResponse("True")

    except:
        return HttpResponse("False")


def staff_feedback_message(request):
    feedbacks = FeedBackStaffs.objects.all()
    context = {"feedbacks": feedbacks}
    return render(request, "hod_template/staff_feedback_template.html", context)


@csrf_exempt
def staff_feedback_message_reply(request):
    feedback_id = request.POST.get("id")
    feedback_reply = request.POST.get("reply")

    try:
        feedback = FeedBackStaffs.objects.get(id=feedback_id)
        feedback.feedback_reply = feedback_reply
        feedback.save()
        return HttpResponse("True")

    except:
        return HttpResponse("False")


def student_leave_view(request):
    leaves = LeaveReportStudent.objects.all()
    context = {"leaves": leaves}
    return render(request, "hod_template/student_leave_view.html", context)


def student_leave_approve(request, leave_id):
    leave = LeaveReportStudent.objects.get(id=leave_id)
    leave.leave_status = 1
    leave.save()
    return redirect("student_leave_view")


def student_leave_reject(request, leave_id):
    leave = LeaveReportStudent.objects.get(id=leave_id)
    leave.leave_status = 2
    leave.save()
    return redirect("student_leave_view")


def staff_leave_view(request):
    leaves = LeaveReportStaff.objects.all()
    context = {"leaves": leaves}
    return render(request, "hod_template/staff_leave_view.html", context)


def staff_leave_approve(request, leave_id):
    leave = LeaveReportStaff.objects.get(id=leave_id)
    leave.leave_status = 1
    leave.save()
    return redirect("staff_leave_view")


def staff_leave_reject(request, leave_id):
    leave = LeaveReportStaff.objects.get(id=leave_id)
    leave.leave_status = 2
    leave.save()
    return redirect("staff_leave_view")


def admin_view_attendance(request):
    subjects = Subjects.objects.all()
    session_years = SessionYearModel.objects.all()
    context = {"subjects": subjects, "session_years": session_years}
    return render(request, "hod_template/admin_view_attendance.html", context)


@csrf_exempt
def admin_get_attendance_dates(request):
    # Getting Values from Ajax POST 'Fetch Student'
    subject_id = request.POST.get("subject")
    session_year = request.POST.get("session_year_id")

    # Students enroll to Course, Course has Subjects
    # Getting all data from subject model based on subject_id
    subject_model = Subjects.objects.get(id=subject_id)

    session_model = SessionYearModel.objects.get(id=session_year)

    # students = Students.objects.filter(course_id=subject_model.course_id, session_year_id=session_model)
    attendance = Attendance.objects.filter(
        subject_id=subject_model, session_year_id=session_model
    )

    # Only Passing Student Id and Student Name Only
    list_data = []

    for attendance_single in attendance:
        data_small = {
            "id": attendance_single.id,
            "attendance_date": str(attendance_single.attendance_date),
            "session_year_id": attendance_single.session_year_id.id,
        }
        list_data.append(data_small)

    return JsonResponse(
        json.dumps(list_data), content_type="application/json", safe=False
    )


@csrf_exempt
def admin_get_attendance_student(request):
    # Getting Values from Ajax POST 'Fetch Student'
    attendance_date = request.POST.get("attendance_date")
    attendance = Attendance.objects.get(id=attendance_date)

    attendance_data = AttendanceReport.objects.filter(attendance_id=attendance)
    # Only Passing Student Id and Student Name Only
    list_data = []

    for student in attendance_data:
        data_small = {
            "id": student.student_id.admin.id,
            "name": student.student_id.admin.first_name
            + " "
            + student.student_id.admin.last_name,
            "status": student.status,
        }
        list_data.append(data_small)

    return JsonResponse(
        json.dumps(list_data), content_type="application/json", safe=False
    )


def admin_profile(request):
    user = CustomUser.objects.get(id=request.user.id)

    context = {"user": user}
    return render(request, "hod_template/admin_profile.html", context)


def admin_profile_update(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method!")
        return redirect("admin_profile")
    else:
        first_name = request.POST.get("first_name")
        last_name = request.POST.get("last_name")
        password = request.POST.get("password")

        try:
            customuser = CustomUser.objects.get(id=request.user.id)
            customuser.first_name = first_name
            customuser.last_name = last_name
            if password != None and password != "":
                customuser.set_password(password)
            customuser.save()
            messages.success(request, "Profile Updated Successfully")
            return redirect("admin_profile")
        except:
            messages.error(request, "Failed to Update Profile")
            return redirect("admin_profile")


def staff_profile(request):
    pass


def student_profile(request):
    return render(request, "hod_template/student_profile_template.html")


def manage_passwords(request):
    students = CustomUser.objects.filter(user_type=3)
    staff = CustomUser.objects.filter(user_type=2)
    context = {"students": students, "staff": staff}
    return render(request, "hod_template/manage_passwords.html", context)


def reset_password(request):
    if request.method == "POST":
        user_id = request.POST.get("user_id")
        new_password = request.POST.get("new_password")
        try:
            user = CustomUser.objects.get(id=user_id)
            user.set_password(new_password)
            user.save()
            messages.success(request, "Password reset successful")
        except CustomUser.DoesNotExist:
            messages.error(request, "User not found")
        except Exception as e:
            messages.error(request, f"Error resetting password: {str(e)}")
    return redirect("manage_passwords")


def change_own_password(request):
    if request.method == "POST":
        old_password = request.POST.get("old_password")
        new_password = request.POST.get("new_password")
        confirm_password = request.POST.get("confirm_password")

        if new_password != confirm_password:
            messages.error(request, "New passwords do not match!")
            return redirect("admin_profile")

        user = request.user
        if user.check_password(old_password):
            user.set_password(new_password)
            user.save()
            messages.success(request, "Password changed successfully")
            return redirect("login")
        else:
            messages.error(request, "Old password is incorrect!")

    return redirect("admin_profile")
