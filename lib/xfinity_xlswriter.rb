require './lib/xfinity'
require 'xlsx_writer'

movies = Xfinity.get_movie_index

doc = XlsxWriter.new

# show TRUE for true but a blank cell instead of FALSE
doc.quiet_booleans!

sheet1 = doc.add_sheet("Movies")

# freeze pane underneath the first (header) row
# sheet1.freeze_top_left = 'A2'

# DATA

m = Xfinity.enhance_movie_with_detail(movies[0])
keys = m.keys

sheet1.add_row(keys)

movies.each_with_index do |m, idx|
  begin
    m = Xfinity.enhance_movie_with_detail( m )
    sheet1.add_row( keys.map{|k| m[k].to_s} )
    puts "Wrote #{idx}/#{movies.count}"
  rescue; end
end

# sheet1.add_row([
#   Date.parse("July 31, 1912"), 
#   "Milton Friedman",
#   "Economist / Statistician",
#   {:type => :Currency, :value => 10_000},
#   500_000,
#   0.31
# ])
# sheet1.add_autofilter 'A1:E1'

# FORMATTING

# doc.page_setup.top = 1.5
# doc.header.right.contents = 'Corporate Reporting'
# doc.footer.left.contents = 'Confidential'
# doc.footer.right.contents = :page_x_of_y

# if you really need images in header/footer: do it in Excel, save, unzip the xlsx... get the .emf files, "cropleft" (if necessary), etc. from there

# left_header_image  = doc.add_image('image1.emf', 118, 107)
# left_header_image.croptop = '11025f'
# left_header_image.cropleft = '9997f'
# center_footer_image = doc.add_image('image2.emf', 116, 36)
# doc.header.left.contents = left_header_image
# doc.footer.center.contents = [ 'Powered by ', center_footer_image ]
# doc.page_setup.header = 0
# doc.page_setup.footer = 0

# OUTPUT

# You should move the file to where you want it
require 'fileutils'
::FileUtils.mv doc.path, 'myfile.xlsx'

# don't forget
doc.cleanup