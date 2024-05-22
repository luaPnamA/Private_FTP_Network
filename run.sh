#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Update package list and install Apache2
apt update
apt install -y apache2

# Create directory structure
mkdir -p /var/www/html/upload/uploads

# Set permissions
chmod 777 /var/www/html/upload/uploads

# Create index.php
cat <<EOL > /var/www/html/upload/index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>Upload Files</title>
</head>
<body>
    <div class="container">
        <h1>Upload Files</h1>
        <div class="upload-section">
            <form action="upload.php" method="post" enctype="multipart/form-data">
                <label for="fileSelect">Select file (max 1GB):</label>
                <input type="file" name="file" id="fileSelect" required>
                <input type="submit" name="submit" value="Upload">
            </form>
        </div>
        <div class="files-section">
            <h2>Uploaded Files</h2>
            <ul>
                <?php
                \$files = array_diff(scandir('uploads'), array('.', '..'));
                foreach (\$files as \$file) {
                    echo "<li><a href='uploads/\$file'>\$file</a></li>";
                }
                if (isset(\$_GET['message'])) {
                    echo "<p>" . htmlspecialchars(\$_GET['message']) . "</p>";
                }
                ?>
            </ul>
        </div>
    </div>
</body>
</html>
EOL

# Create style.css
cat <<EOL > /var/www/html/upload/style.css
body {
    font-family: Arial, sans-serif;
    background-color: #f0f0f0;
    color: #333;
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}

.container {
    background: #fff;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    width: 80%;
    max-width: 600px;
    text-align: center;
}

h1 {
    color: #4CAF50; /* 60% of the color scheme */
}

.upload-section, .files-section {
    margin: 20px 0;
}

form {
    background: #e0f7fa; /* 30% of the color scheme */
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

form label {
    display: block;
    margin-bottom: 10px;
}

form input[type="file"] {
    margin-bottom: 10px;
}

form input[type="submit"] {
    background-color: #4CAF50;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
}

form input[type="submit"]:hover {
    background-color: #45a049;
}

.files-section ul {
    list-style: none;
    padding: 0;
}

.files-section li {
    background: #f9f9f9; /* 10% of the color scheme */
    margin: 5px 0;
    padding: 10px;
    border-radius: 5px;
    box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
}

.files-section a {
    text-decoration: none;
    color: #333;
}

.files-section a:hover {
    text-decoration: underline;
}
EOL

# Create upload.php
cat <<EOL > /var/www/html/upload/upload.php
<?php
if (\$_SERVER['REQUEST_METHOD'] == 'POST') {
    \$target_dir = "uploads/";
    \$target_file = \$target_dir . basename(\$_FILES["file"]["name"]);
    \$uploadOk = 1;
    \$fileType = strtolower(pathinfo(\$target_file, PATHINFO_EXTENSION));

    // Check file size
    if (\$_FILES["file"]["size"] > 1073741824) { // 1GB
        \$message = "Sorry, your file is too large.";
        \$uploadOk = 0;
    }

    if (\$uploadOk == 0) {
        \$message = "Sorry, your file was not uploaded.";
    } else {
        if (move_uploaded_file(\$_FILES["file"]["tmp_name"], \$target_file)) {
            \$message = "The file " . htmlspecialchars(basename(\$_FILES["file"]["name"])) . " has been uploaded.";
        } else {
            \$message = "Sorry, there was an error uploading your file.";
        }
    }

    // Redirect to the index page with the message
    header("Location: index.php?message=" . urlencode(\$message));
    exit;
}
?>
EOL

# Restart Apache2 to apply changes
systemctl restart apache2

# Instructions to the user
echo "Setup complete. Open a web browser and navigate to http://your_server_ip/upload/ to test the file upload functionality."
