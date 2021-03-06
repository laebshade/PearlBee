package PearlBee::Authorization;

use Dancer2;

=head

Check if the user has authorization

=cut

hook 'before' => sub {
  my $user = session('user');

  # Check if the user is logged in
  my $request = request->path_info;
  if ( $request =~ /admin/ && !$user ) {
    redirect session('app_url') . '/admin' ;
  }

  # Check if the user is activated
  if ( $request !~ /\/dashboard/ && $user) {
    redirect session('app_url') . '/dashboard'  if ( $user->status eq 'deactivated' );
  }

  # Restrict access to non-admin users
  if ( $request =~ '/admin/' && $user->is_author ) {
    redirect session('app_url') . '/author/posts/add' ;
  }
};

1;