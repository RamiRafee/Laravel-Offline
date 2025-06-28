<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Manager</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <div id="globe-background" style="position: fixed; top:0; left:0; width:100%; height:100%; z-index:-1;"></div>

    <div class="container mt-5">
        <h1 class="mb-4">Task Manager</h1>

        <input class="form-control mb-3 search" placeholder="Search Tasks" />

        <div id="task-list">
            <table class="table table-dark table-striped">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody class="list">
                    <tr>
                        <td class="task-title">Fix bug #123</td>
                        <td class="task-status">Pending</td>
                    </tr>
                    <tr>
                        <td class="task-title">Write unit tests</td>
                        <td class="task-status">Completed</td>
                    </tr>
                    <tr>
                        <td class="task-title">Deploy to staging</td>
                        <td class="task-status">In Progress</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</body>

</html>
