class Worker {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final double balance;
  final bool isOnline;
  final bool isLowBalance;
  final String location;

  const Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.balance,
    this.isOnline = false,
    this.isLowBalance = false,
    this.location = 'Unknown',
  });
}

const List<Worker> kMockWorkers = [
  Worker(
    id: '1',
    name: 'Alex Morgan',
    role: 'Senior Barista',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSSojdjgfCe2RmUY63h4mB9QUSJwVVOPHhdiEUdLUWExhFVUAblBlji-UB_DCI2be0KZbrCCkffqFGVymmUKOLawg3AYFh6FflKoEGFKJ93SbDM8okcJEl3ovmvIR9s2z0u7zmp7LGl9qKbduWv3Vu-oGz_0cSgJYXKrHJ14nGiqF3KoG0Df5kVctxMmWg4AWHNVNOILtFAXldMBPkCcYnANaG9ELEJgtKzbUL2TcFtvAx7waumnPy1RU8ScgtJmoFAH2OCirwC_c',
    balance: 150.00,
    isOnline: true,
    location: 'Downtown',
  ),
  Worker(
    id: '2',
    name: 'Sarah Jenkins',
    role: 'Head Roaster',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDYXFFOR_lxcNtbru27xAFzm-HZgRE-UnD8_BttZFW6CSEK7H9gm6J1ND2NJHGlLag4uI4flb0-LQmodehJLmnrR2B1B4XtVcXbmyM87f-D2Aey7yvxx9vua5RzqamfbIkFC4xttx39Z1-6LaUgixAloUNwUHKEEi5E5K9dH_cbmLFE3aTKiAJwdhHUeefWoNxYOCkfW4IpnGHCVOggEoeHg_15gGhgcDWddpwysdYOWysEpX3drwI_EEwFdsBivz5mXJci9WBGFdY',
    balance: 45.50,
    isLowBalance: true,
    location: 'Uptown',
  ),
  Worker(
    id: '3',
    name: 'Mike Thompson',
    role: 'Store Manager',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKVjyjIgCXbk5DNM0w28KmCWk_z6BcWQ8_Pmte8FYiLXN--HfEPy5x3ldHP0F5tqMA3WeAU1BzMjQmQhdJO-zitL1ycHmUwCzwZPXC4E1LetV3emfi_xbKIJjdvVjRJNL8wa2iqayiN9t1Arb793PDcyq54g14RDMAyYGzrNfxmHuoK3ohmqt0NrwNc-91s2vbPHjcdHFZS5PpSNDr9yXxS6xuwF3q4dSWtttvf3S-MfdOZhwa8m4TwY3BPpIKZo3aWVDssTvvC-E',
    balance: 200.00,
    isOnline: false,
     location: 'Westside',
  ),
  Worker(
    id: '4',
    name: 'Emily Rivera',
    role: 'Server',
    avatarUrl: '', // Fallback initials
    balance: 85.25,
    isOnline: false,
    location: 'Downtown',
  ),
   Worker(
    id: '5',
    name: 'David Chen',
    role: 'Barista (On Leave)',
    avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCtNg4xLJ3lb8XVA4JJOrVqAgSGKeqFzXX2HG0IO98pnW9NYtb1MDS-iHAwVqDfFNjqq9JhBF4TmgaRX3qo_8VInqr-El1l0C-tEXEXP_uY-cFhzxgGMAUI88IgxgZnPkPYQWfCJEuFECygcp3eN3EtE9r_MTlghoc_qMp9KJ4Tsb5tjgS8K1BO-THieg8s4sKHaqRp4YlUEsyRa8_cwutS9mh5dxh9mzsfqzL4gb5erQQXcwSuJdIxdhRXqAO46YkpLZ_vZI4UBzk',
    balance: 0.00,
    isOnline: false,
    location: 'North',
    // grayscale in logic
  ),
];
