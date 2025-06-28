<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Manager</title>
    @vite(['resources/js/app.js'])
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
</head>
<body>
<div id="vanta-bg" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: -1;"></div>

<div class="container py-5">
    <h1 class="mb-4">Task Manager</h1>

    {{-- Add Task --}}
    <form action="{{ route('tasks.store') }}" method="POST" class="d-flex mb-4">
        @csrf
        <input type="text" name="title" class="form-control me-2" placeholder="New Task" required>
        <button class="btn btn-primary">Add</button>
    </form>

    {{-- Task List --}}
    <ul class="list-group">
        @foreach ($tasks as $task)
            <li class="list-group-item d-flex justify-content-between align-items-center">
                <form action="{{ route('tasks.update', $task) }}" method="POST" class="d-flex w-100">
                    @csrf
                    @method('PUT')
                    <input type="text" name="title" value="{{ $task->title }}" class="form-control me-2">
                    <input type="checkbox" name="completed" {{ $task->completed ? 'checked' : '' }} class="form-check-input me-2">
                    <button class="btn btn-success btn-sm me-2">Update</button>
                </form>
                <form action="{{ route('tasks.destroy', $task) }}" method="POST">
                    @csrf
                    @method('DELETE')
                    <button class="btn btn-danger btn-sm">Delete</button>
                </form>
            </li>
        @endforeach
    </ul>
</div>
</body>
</html>
