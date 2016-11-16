class ManageZillowKey
  @@keys = {
    "X1-ZWz1aylbpp3aiz_98wrk": 0,
    "X1-ZWz19jyb3om7t7_8jmj2": 0,
    "X1-ZWz1fgk9st8tmz_8l13j": 0,
    "X1-ZWz19jy75me3uz_8mfo0": 0,
    "X1-ZWz1fgkdqvgxl7_8nu8h": 0,
    "X1-ZWz19jy37k5zwr_8p8sy": 0,
    "X1-ZWz1fgkhoxp1jf_8qndf": 0,
    "X1-ZWz19jxz9hxvyj_8s1xw": 0,
    "X1-ZWz1a4mphgfggb_7zykg": 0
  }

  def self.set_zillow_key(key)
    @@keys[key.to_sym] += 1
  end

  def self.get_zillow_key
    key = @@keys.min_by{|k,v| v}
    set_zillow_key(key[0])

    key[0]
  end

  def self.get_all
    @@keys
  end

  def self.reset_count
    @@keys = {
      "X1-ZWz1aylbpp3aiz_98wrk": 0,
      "X1-ZWz19jyb3om7t7_8jmj2": 0,
      "X1-ZWz1fgk9st8tmz_8l13j": 0,
      "X1-ZWz19jy75me3uz_8mfo0": 0,
      "X1-ZWz1fgkdqvgxl7_8nu8h": 0,
      "X1-ZWz19jy37k5zwr_8p8sy": 0,
      "X1-ZWz1fgkhoxp1jf_8qndf": 0,
      "X1-ZWz19jxz9hxvyj_8s1xw": 0,
      "X1-ZWz1a4mphgfggb_7zykg": 0
    }
  end
end