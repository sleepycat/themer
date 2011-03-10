module EftPlus
  class FreeCssTemplates

#mike@sleepycat:~/projects/eftplus$ /home/mike/projects/themer_test/themer concurrence
#There is no public/site/themes directory in this folder.
#There is no public/site/themes directory in this folder.
#Couldn't find a tag matching //link.
#Couldn't find a tag matching //*[@class='post']//*[@class='entry'].
#Couldn't find a tag matching //*[@class='post']//*[@class='meta'].
#Couldn't find a tag matching //*[@class='post']//*[@class='title'].



    require 'rubygems'
    require 'zip/zip'
    require 'net/http'
    require 'open-uri'
    require 'zlib'
    require 'fileutils'

    def install_theme name
      @themes_dir = File.join(%W(public site themes))
      download_theme name
      download_theme_image name
      copy_to_app_views name
    end

    def public_site_themes?
      File.directory?(@themes_dir)
    end

    def download_theme name
      if public_site_themes?
        url = 'http://www.freecsstemplates.org/download/zip/'
        #the website will sever the connection without the user-agent and other stuff.
        begin
          open( url + name, "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.9) Gecko/20100402 Ubuntu/9.10 (karmic) Firefox/3.5.9", "From" => "foo@bar.invalid", "Referer" => "http://www.ruby-lang.org/") {|zf|
            unzip zf.path, File.join(@themes_dir, name)
          }
        rescue OpenURI::HTTPError => e
          puts "The site returned #{e}"
          exit
        end

      else
        puts "There is no public/site/themes directory in this folder."
        exit
      end
    end

    def download_theme_image name
      if public_site_themes?
        url = 'http://www.freecsstemplates.org/download/thumbnail/'
        begin
        File.open(File.join(@themes_dir, name, "#{name}.gif"), 'w+') do |local_file|
          open( url + name, "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.9) Gecko/20100402 Ubuntu/9.10 (karmic) Firefox/3.5.9", "From" => "foo@bar.invalid", "Referer" => "http://www.ruby-lang.org/") do |remote_file|
            local_file << remote_file.read
          end
        end
        rescue OpenURI::HTTPError => e
          puts e
        end

      else
        puts "There is no public/site/themes directory in this folder."
        exit
      end
    end

    def copy_to_app_views name
      if File.directory?(File.join(%w(app views layouts themes))) && File.directory?(@themes_dir)
        begin
          FileUtils.mkdir(File.join(%W(app views layouts themes #{name}))) unless File.exists? File.join(%W(app views layouts themes #{name}))

          FileUtils.cp(File.join(%W(public site themes #{name} index.html)),  File.join(%W(app views layouts themes #{name} layout.html.erb)))
          puts "Copied layout.html.erb"
          FileUtils.cp(File.join(%W(public site themes #{name} style.css)),  File.join(%W(app views layouts themes #{name} style.css)))
          puts "Copied style.css"
        rescue Exception => e
          puts "#{e}"
        end
      end
    end

    protected

    def unzip compressed_file, destination_dir
      #zf is an instance of class Tempfile
      Zip::ZipFile.open(compressed_file) do |zipfile|
        #zipfile.class is Zip::ZipFile
        zipfile.each{|e|
          #e is an instance of Zip::ZipEntry
          fpath = File.join(destination_dir, e.to_s)
          FileUtils.mkdir_p(File.dirname(fpath))
          #the block is for handling an existing file. returning true will overwrite the files.
          zipfile.extract(e, fpath){ true }
        }
      end
    end

  end
end