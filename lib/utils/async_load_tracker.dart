/// Used to track whether loading has been cancelled or overridden by another load
/// The tracker object issues tickets, and only the latest ticket is valid
/// If a ticket is invalid then the result of the load _must_ be discarded
class AsyncLoadTracker {
  AsyncLoadTracker();

  LoadTicket _ticket;

  LoadTicket getTicket() {
    final ticket = LoadTicket(this);
    _ticket = ticket;
    return ticket;
  }

  bool isTicketValid(LoadTicket ticket) {
    final latest = _ticket;
    return latest == null || latest == ticket;
  }
}

class LoadTicket {
  LoadTicket(this._tracker);

  final AsyncLoadTracker _tracker;

  bool get isValid => _tracker.isTicketValid(this);
}
