# -*- coding: utf-8 -*-
require 'sanitize'
class Review < ActiveRecord::Base
  belongs_to :product
  has_many   :feedback_reviews

  include Rakismet::Model
  rakismet_attrs :author => :name,
  :content => :review,
  :author_email => :email

  validates_presence_of :name
  validates :review, :presence => true, :uniqueness => true, :length => { :minimum => 50 }
  validates_numericality_of :rating, :only_integer => true, :message => I18n::t('you_need_to_rate_your_review')

  default_scope order("reviews.created_at DESC")
  scope :approved,  where("approved = ?", true)
  scope :not_approved, where("approved = ?", false)

  scope :approval_filter, lambda {|*args| {:conditions => ["(? = ?) or (approved = ?)", Spree::Reviews::Config[:include_unapproved_reviews], true, true ]}}

  scope :oldest_first, :order => "created_at asc"
  scope :preview,      :limit => Spree::Reviews::Config[:preview_size], :order=>"created_at desc"

  def feedback_stars
    return 0 if feedback_reviews.count <= 0
    ((feedback_reviews.sum(:rating)/feedback_reviews.count) + 0.5).floor
  end

  def before_save 
    self.review = Sanitize.clean(self.review, Sanitize::Config::RESTRICTED)
  end 


  private
  def allow_some_html(s) 
    # converting newlines 
    s.gsub!(/\r\n?/, "\n") 
    
    # escaping HTML to entities 
    s = s.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;') 
    
    # blockquote tag support 
    s.gsub!(/\n?&lt;blockquote&gt;\n*(.+?)\n*&lt;\/blockquote&gt;/im, "<blockquote>\\1</blockquote>") 
    
    # other tags: b, i, em, strong, u 
    %w(b i em strong u).each { |x|
      s.gsub!(Regexp.new('&lt;(' + x + ')&gt;(.+?)&lt;/('+x+')&gt;',
                         Regexp::MULTILINE|Regexp::IGNORECASE), 
              "<\\1>\\2</\\1>") 
    } 
    
    # A tag support 
    # href="" attribute auto-adds http:// 
    s = s.gsub(/&lt;a.+?href\s*=\s*['"](.+?)["'].*?&gt;(.+?)&lt;\/a&gt;/im) { |x|
      '<a href="' + ($1.index('://') ? $1 : 'http://'+$1) + "\">" + $2 + "</a>" 
    } 
    
    # replacing newlines to <br> ans <p> tags 
    # wrapping text into paragraph 
    s = "<p>" + s.gsub(/\n\n+/, "</p>\n\n<p>").
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />') + "</p>" 
    
    s      
  end 

end
