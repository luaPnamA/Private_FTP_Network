# Create Your Own Private FTP Network Using Apache2 on Any Linux-Based OS

This project will guide you through setting up your own private FTP network using Apache2 as the server on any Linux-based operating system. You will create a folder structure within `/var/www/html` to enable file uploads.

## Quick Setup Guide

### Automated Setup

You can automate the entire setup process by downloading and running the `run.sh` script. 

#### Steps:
1. Download the `run.sh` file.
2. Run the script with root privileges:
   ```sh
   sudo bash run.sh
   ```
   
### Manual Setup

If you prefer to set up the network manually, follow the steps below.

## Prerequisites

- Basic knowledge of Linux command-line interface.
- A Linux-based operating system installed and configured.
- Apache2 installed on your system.

## Step-by-Step Instructions

### 1. Install Apache2

Update the package list and install Apache2:
```sh
sudo apt update
sudo apt install -y apache2
```

### 2. Create Directory Structure

Navigate to the web root directory:
```sh
cd /var/www/html
```

Create the `upload` directory and an `uploads` subdirectory:
```sh
sudo mkdir -p upload/uploads
```

### 3. Set Permissions

Ensure the `uploads` directory is writable:
```sh
sudo chmod 777 upload/uploads
```

### 4. Create `index.php`

Navigate to the `upload` directory:
```sh
cd /var/www/html/upload
```

Create and edit `index.php`:
```sh
sudo nano index.php
```

Add the following content to `index.php`:
```php
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
                $files = array_diff(scandir('uploads'), array('.', '..'));
                foreach ($files as $file) {
                    echo "<li><a href='uploads/$file'>$file</a></li>";
                }
                if (isset($_GET['message'])) {
                    echo "<p>" . htmlspecialchars($_GET['message']) . "</p>";
                }
                ?>
            </ul>
        </div>
    </div>
</body>
</html>
```

### 5. Create `style.css`

Create and edit `style.css`:
```sh
sudo nano style.css
```

Add the following content to `style.css`:
```css
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
```

### 6. Create `upload.php`

Create and edit `upload.php`:
```sh
sudo nano upload.php
```

Add the following content to `upload.php`:
```php
<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $target_dir = "uploads/";
    $target_file = $target_dir . basename($_FILES["file"]["name"]);
    $uploadOk = 1;
    $fileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    // Check file size
    if ($_FILES["file"]["size"] > 1073741824) { // 1GB
        $message = "Sorry, your file is too large.";
        $uploadOk = 0;
    }

    if ($uploadOk == 0) {
        $message = "Sorry, your file was not uploaded.";
    } else {
        if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
            $message = "The file " . htmlspecialchars(basename($_FILES["file"]["name"])) . " has been uploaded.";
        } else {
            $message = "Sorry, there was an error uploading your file.";
        }
    }

    // Redirect to the index page with the message
    header("Location: index.php?message=" . urlencode($message));
    exit;
}
?>
```

### 7. Restart Apache2

Any changes made to the configuration files or directory structure will require restarting Apache2 to take effect:
```sh
sudo systemctl restart apache2
```

### 8. Test the Setup

Open a web browser and navigate to `http://your_server_ip/upload/`.
- Use the form to upload a file and check the `uploads` directory to ensure the file is stored correctly.
- Verify the uploaded files list is displayed correctly.

## Troubleshooting

- Ensure Apache2 is running:
  ```sh
  sudo systemctl status apache2
  ```
- Check file and directory permissions if uploads fail.

By following this guide, you can create a secure and private FTP network using Apache2 for easy file sharing on your Linux system.
