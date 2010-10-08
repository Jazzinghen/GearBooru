#!/usr/bin/ruby

require 'rubygems'
require 'open-uri'
require 'hpricot'

@user_agent = "Mozilla/5.0"

def gel_link_fetch(url)
    response = ''

    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
    open(url, "User-Agent" => @user_agent,
        "From" => "email@addr.com",
        "Referer" => "http://www.gelbooru.com/") { |f|
     
        # Save the response body
        response = f.read
    }

    #Rdoc: http://code.whytheluckystiff.net/hpricot/
    doc = Hpricot(response)

    arr=[]
    (doc/"/html/body/div[6]/div/div[2]/div[2]/span/a").each do |entry|
        arr << entry.get_attribute("href").to_s
    end
    return arr
end
 
def gel_search_res(url)
    response = ''

    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
    open(url, "User-Agent" => @user_agent,
        "From" => "email@addr.com",
        "Referer" => "http://www.gelbooru.com/") { |f|
     
        # Save the response body
        response = f.read
    }

    #Rdoc: http://code.whytheluckystiff.net/hpricot/
    doc = Hpricot(response)

    str = (doc/"a[@alt='last page']").first.get_attribute("href")
    
    return str.split("=").last.to_i
end

def gel_fullsize_links(url)
    response = ''

    # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
    open(url, "User-Agent" => @user_agent,
        "From" => "email@addr.com",
        "Referer" => "http://www.gelbooru.com/") { |f|
     
        # Save the response body
        response = f.read
    }

    #Rdoc: http://code.whytheluckystiff.net/hpricot/
    doc = Hpricot(response)

    image = doc.search('a[text()="Original image"]').first.get_attribute("href")
    
    rating = (doc/'//*[@id="stats"]').search('li[text()*="Rating"]').inner_text.split(' ').last
    
    return [image,rating]    
end

def gel_img_download(url, imgFold)
    imgName = url.split("/").last
    
    newImage = open(imgFold + imgName, "wb")
    newImage.write(open(url).read)
    newImage.close    
end

def gen_folders(folder)
    #   Non funziona se voglio creare una cartella in una cartella che non esiste
    Dir.mkdir(folder) unless File.directory?(folder)

    ["Safe", "Questionable", "Explicit"].each do |rating|
        Dir.mkdir(folder+"#{rating}/") unless File.directory?(folder+"#{rating}/")
    end
end

def main()
    searchTerms = "agarest_senki"
    gelbooru_root   = "http://www.gelbooru.com/"
    gelbooru_search = "index.php?page=post&s=list&tags="
    folder = searchTerms + "/"
    res = gel_search_res(gelbooru_root + gelbooru_search + searchTerms)
    pages = res/25
    links = []
    
    0.upto(pages) do |i|
        gel_pid = i*25
        page_link = "#{gelbooru_root}#{gelbooru_search}#{searchTerms}&pid=#{gel_pid}"
        links += gel_link_fetch(page_link)
    end
    
    img_links = []
    
    links.each_index do |index|
        puts "Fetching Image Link #{index+1} of #{links.size}"
        img_links << gel_fullsize_links(gelbooru_root + links[index])
    end
    
    gen_folders(folder)
    
    img_links.each_index do |index|
        puts "Downloading Image #{index+1} of #{img_links.size}"
        gel_img_download(img_links[index][0], folder+img_links[index][1]+"/")
    end
    
end

main

#scarica(gelbooru)
