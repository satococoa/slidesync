class Slideshare
  BASE_URL = 'http://www.slideshare.net/api/2/'
  RETRY_MAX = 3
  cattr_accessor :key, :secret

  class << self
    def configure
      yield self
    end

    def search(keyword, page=0)
      search_slideshows(q: keyword, page: page, detailed: 1)
    end

    def find_by_url(url)
      get_slideshow(slideshow_url: url, detailed: 1)
    end

    def find(id)
      get_slideshow(slideshow_id: id, detailed: 1)
    end

    private
    def search_slideshows(options)
      result = query('search_slideshows', options)
      res = result['Slideshows']
      if res['Slideshow'].present?
        slides = res['Slideshow'].map{|slide| parse_slide(slide)}
      else
        slides = []
      end
      meta = res['Meta']
      results = meta['NumResults']
      total = meta['TotalResults']
      Hashie::Mash.new(slides: slides, results: results, total: total.to_i, page: options[:page])
    end

    def get_slideshow(options)
      # 使いそうな属性はID, Title, ThumbnailSmallURL, Username, PPTLocation
      result = query('get_slideshow', options)
      raise 'There is no slide with specified id.' if result['Slideshow'].nil?
      slide = parse_slide(result['Slideshow'])
      Hashie::Mash.new(slide)
    end

    def parse_slide(slide)
      {id: slide['ID'],
       title: slide['Title'],
       thumbnail: slide['ThumbnailSmallURL'],
       username: slide['Username'],
       doc: slide['PPTLocation'],
       description: slide['Description']
      }
    end
    def query(method, options)
      url = BASE_URL+method
      query = options.merge(essential_queries)
      client = HTTPClient.new

      begin
        res = client.get(url, query)
        parse res.body
      rescue => e
        retry_count ||= 0
        retry_count += 1
        retry if retry_count < RETRY_MAX
        raise e
      end
    end
    def parse(xml)
      Hash.from_xml(xml)
    end
    def essential_queries
      ts = Time.now.to_i.to_s
      hash = Digest::SHA1.hexdigest(@@secret + ts.to_s)
      {api_key: @@key, ts: ts, hash: hash}
    end
  end
end
