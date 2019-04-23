from django.http import HttpResponse
from django.shortcuts import render, redirect
import json
from forum.models import Topic, Post
from people.models import Person


def main(request):
    if request.method == "POST":
        post = json.loads(request.body)
        name = post['postName']
        posts = [
            {"title": x.title,
             "id": x.id}
            for x in Post.objects.filter(title__contains=name)
        ]
        return HttpResponse(json.dumps(posts))

    posts = [
        {"title": x.title,
         "id": x.id}
        for x in Post.objects.all()
    ]
    return render(request, "forum/forum.html", context={"posts": posts})


def view_post(request, post_id):
    post = Post.objects.get(pk=post_id)
    context = {
        "title": post.title,
        "body": post.body,
        "id": post.pk,
        "canEdit": post.owner.user is request.user,
    }
    return render(request, "forum/post.html", context=context)


def create_post(request):
    if not request.user.is_authenticated:
        return redirect("people:login")
    if request.method == "POST":
        post = json.loads(request.body)
        title = post['title']
        body = post['body']
        topic = Topic.objects.get(name=post['topic'])
        user = Person.objects.get(user=request.user)
        try:
            new_post = Post(title=title, body=body, owner=user, topic=topic)
            new_post.save()
        except Exception as e:
            print(e)
            return HttpResponse("Failed server error.")
        return HttpResponse("")
    topics = [x.name for x in Topic.objects.all()]
    return render(request, "forum/create_post.html",
                  context={"topics": topics})


def edit_posts(request, post_id):
    return HttpResponse('Edit Post, id: ' + str(post_id))
