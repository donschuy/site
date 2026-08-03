---
layout: ../../layouts/PageLayout.astro
title: 'How I create a page on my site'
pubDate: 2026-08-02
description: 'How I create a new page on my activity book site.'
author: 'Don Schuy'
tags: ["dev"]
---
# How I create a page on my site
*August 3, 2026*

Here I'll document how I create pages on my site for those that are interested. My goal is to be able to make a page as effortlessly as possible
so I'll be encouraged to post often.

My site is hosted on Cloudflare using the free plan. I pay only for the domain name which is around $12 a year. I followed the [documented instructions
for how to add Cloudflare pages to GitHub](https://developers.cloudflare.com/pages/configuration/git-integration/github-integration/). With this integration, my
site files are stored in a GitHub repository and each time I push a change to GitHub, the Cloudflare site is automatically updated.

I'm using the [Astro web framework](https://astro.build/) for the site. I got familiar with the [Astro documentation](https://docs.astro.build/en/getting-started/) and followed the tutorial. Initially, I also researched using available site templates, however, I opted to build the site from scratch so
that I would know how everything worked.

The framework generates static web pages from .astro files and Markdown .md files. It also introduces the use of .mdx files for Markdown files that contain React
framework components. The framework is elegant in every way and I'm only using a very small portion of its features at the moment, but I know I can dig into more
capabilities as I find need to.

The process for creating a page on my site starts with selecting a set of pictures from my phone. In my case, I'm using an iPhone, which creates .heic files.
These .heic files need to be converted to something displayable on any browser. The .webp file format is preferable as it is compact and displays on all
modern web browsers.

First, I need to get the files on my computer. There are many ways to do that. I happen to be using [Google Drive](https://drive.google.com/) as I don't have
anything else currently on it so I can use that online space as a temporary way to upload the files from the phone which then syncs to a folder on my computer.
Google Drive has an iPhone app that I can use to select photos for upload.

Once the files are uploaded and synced on my computer, I use a web browser tool, [HEIC to WebP Converter](https://heicsave.com/heic-to-webp), to do the
conversion to .webp for free. The tool does the conversion within the browser and does not upload the content to any server. In the tool, I set the maximum
width of an image to 2,048 pixels, which helps reduce the file size. The original horizontal layout pictures are 5,712 pixel width and the original vertical
layout pictures are 4,284 pixels. Most viewers will be looking at the photos on their phone and a lower resolution loads faster and appears fine with a
reasonable loss of quality.

The converted pictures are "downloaded" from the browser application to the computer in the form of a .ZIP file. The conversion goes fast enough that I convert
all of my pictures of the event to .webp before bothering to filter out the photos I don't want.

I unzip the images into a folder and then delete the ones I don't want. This actually is the longest part of the effort as I'm deciding what is the
content of the page at that point. For events I want to tell the story more than just keep the best looking photos. I start thinking roughly about what the 
dialog on the page is going to be while I'm choosing the images.

I then copy the images to a folder under my project's "images" folder. I execute an [assetopt utility](https://assetopt.tech/) to compress the files further.
````bash
> assetopt optimize ./images/fallen-leaf-lake --output ./public/fallen-leaf-lake
````

The resulting folder within the "public" folder is where the images will be referenced by the site pages.

I then create a link to the new page on the index.astro page which is the home page of the site.
````HTML
<li>
  <a href="/travel/fallen-leaf-lake">Fallen Leaf Lake</a>
  <div class="entry-date">July 29, 2026</div>
</li>
````

Next I create a text file with the names of the images. I use:

````bash
> ls > dir.txt
````

This generates a file like this:

````
    Directory: C:\Users\donsc\Documents\sites\don\public\fallen-leaf-lake


Mode                 LastWriteTime         Length Name                                      
----                 -------------         ------ ----                                      
-a----          8/3/2026  12:02 AM           2000 .assetopt-cache.json
-a----          8/3/2026  12:17 AM              0 dir.txt
-a----          8/3/2026  12:02 AM         650196 IMG_1613.webp
-a----          8/3/2026  12:02 AM         571674 IMG_3872.webp
-a----          8/3/2026  12:02 AM         169650 IMG_3884.webp
-a----          8/3/2026  12:02 AM         288624 IMG_3885.webp
-a----          8/3/2026  12:02 AM         102868 IMG_3888.webp
-a----          8/3/2026  12:02 AM         109508 IMG_3890.webp
-a----          8/3/2026  12:02 AM         688020 IMG_3896.webp
-a----          8/3/2026  12:02 AM         777952 IMG_3900.webp
-a----          8/3/2026  12:02 AM         671944 IMG_3904.webp
````

In VS Code I can highlight the ".webp" extension on the first file name, then use the "Selection" - "Select All Occurrences" command.
I'll make some edits to result in a file like this which is the markup for the images.

````
![](/fallen-leaf-lake/IMG_1613.webp)

![](/fallen-leaf-lake/IMG_3872.webp)

![](/fallen-leaf-lake/IMG_3884.webp)

![](/fallen-leaf-lake/IMG_3885.webp)

![](/fallen-leaf-lake/IMG_3888.webp)

![](/fallen-leaf-lake/IMG_3890.webp)

![](/fallen-leaf-lake/IMG_3896.webp)

![](/fallen-leaf-lake/IMG_3900.webp)

![](/fallen-leaf-lake/IMG_3904.webp)
````

I'll add a data section at the the top of the page, a heading title and date, one or two links about the location, and some narrative to go along with the pictures.

The resulting Markdown looks like this:

````markdown
---
layout: ../../layouts/PageLayout.astro
title: 'Fallen Leaf Lake'
pubDate: 2026-08-03
description: 'Family gathering at Fallen Leaf Lake in the Lake Tahoe area'
author: 'Don Schuy'
tags: ["travel"]
---
# Fallen Leaf Lake
*July 29, 2026*

[Wikipedia](https://en.wikipedia.org/wiki/Fallen_Leaf_Lake) page.
[Recreation.gov](https://www.recreation.gov/camping/campgrounds/232769) campground page.

This afternoon we visited Fallen Leaf Lake with family for a swim, lunch and picture taking.

![](/fallen-leaf-lake/IMG_3872.webp)

The water was warm for wading and swimming. I captures photos and portraits of the ladies.

![](/fallen-leaf-lake/IMG_3884.webp)

![](/fallen-leaf-lake/IMG_1613.webp)

![](/fallen-leaf-lake/IMG_3888.webp)

![](/fallen-leaf-lake/IMG_3890.webp)

My wife's cousin brought full Hmong ornamental dress for a photo shoot in this great setting.

![](/fallen-leaf-lake/IMG_3896.webp)

We had a relaxed time after our previous days of hiking.

![](/fallen-leaf-lake/IMG_3900.webp)

![](/fallen-leaf-lake/IMG_3885.webp)

![](/fallen-leaf-lake/IMG_3904.webp)

````

The resulting page is [here](/travel/fallen-leaf-lake).