=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Comment;

use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

get '/admin/comments' => sub { redirect session('app_url') . '/admin/comments/page/1' };

=head

List all comments

=cut

get '/admin/comments/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page        = params->{page} || 1;
  my @comments    = resultset('Comment')->search({}, { order_by => { -desc => "comment_date" }, rows => $nr_of_rows, page => $page });
  my $all         = resultset('Comment')->search({})->count;
  my $approved    = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash       = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam        = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending     = resultset('Comment')->search({ status => 'pending' })->count;

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/comments');

  # Generating the pagination navigation
  my $total_comments  = $all;
  my $posts_per_page  = $nr_of_rows;
  my $current_page    = $page;
  my $pages_per_set   = 7;
  my $pagination      = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);

  template '/admin/comments/list',
      {
        comments      => \@comments,
        all           => $all,
        approved      => $approved,
        spam          => $spam,
        pending       => $pending,
        trash         => $trash,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'admin/comments/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head

List all spam comments

=cut

get '/admin/comments/:status/page/:page' => sub {

  my $nr_of_rows  = 5; # Number of posts per page
  my $page        = params->{page} || 1;
  my $status      = params->{status};
  my @comments    = resultset('Comment')->search({ status => $status  }, { order_by => { -desc => "comment_date" }, rows => $nr_of_rows, page => $page });
  my $all         = resultset('Comment')->search({ 1 => '1'})->count;
  my $approved    = resultset('Comment')->search({ status => 'approved' })->count;
  my $trash       = resultset('Comment')->search({ status => 'trash' })->count;
  my $spam        = resultset('Comment')->search({ status => 'spam' })->count;
  my $pending     = resultset('Comment')->search({ status => 'pending' })->count;
  
  my $status_count = resultset('Comment')->search({ status => $status })->count;

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/comments/' . $status );

  # Generating the pagination navigation
  my $total_comments  = $status_count;
  my $posts_per_page  = $nr_of_rows;
  my $current_page    = $page;
  my $pages_per_set   = 7;
  my $pagination      = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);


  template '/admin/comments/list',
      {
        comments      => \@comments,
        all           => $all,
        approved      => $approved,
        spam          => $spam,
        pending       => $pending,
        trash         => $trash,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'admin/comments/' . $status . '/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head

Accept comment

=cut

get '/admin/comments/approve/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'approved'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Trash a comment

=cut

get '/admin/comments/trash/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'trash'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Spam a comment

=cut

get '/admin/comments/spam/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'spam'
      });
  };

  redirect session('app_url') . '/admin/comments';
};

=haed

Pending a comment

=cut

get '/admin/comments/pending/:id' => sub {

  my $comment_id = params->{id};
  my $comment = resultset('Comment')->find( $comment_id );

  eval {
    $comment->update({
        status => 'pending'
      });
  };

  redirect session('app_url') . '/admin/comments';
};


1;