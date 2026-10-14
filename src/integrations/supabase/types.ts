export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      agences: {
        Row: {
          adresse: string | null
          cree_le: string
          cree_par: string | null
          devise: string
          fin_essai: string
          id: string
          nom: string
          paye_jusqu_au: string | null
          plan_code: string
          tel: string | null
        }
        Insert: {
          adresse?: string | null
          cree_le?: string
          cree_par?: string | null
          devise?: string
          fin_essai: string
          id?: string
          nom: string
          paye_jusqu_au?: string | null
          plan_code?: string
          tel?: string | null
        }
        Update: {
          adresse?: string | null
          cree_le?: string
          cree_par?: string | null
          devise?: string
          fin_essai?: string
          id?: string
          nom?: string
          paye_jusqu_au?: string | null
          plan_code?: string
          tel?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "agences_plan_code_fkey"
            columns: ["plan_code"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["code"]
          },
        ]
      }
      enregistrements: {
        Row: {
          agence_id: string
          collection: string
          data: Json
          id: string
          maj: string
          maj_par: string | null
        }
        Insert: {
          agence_id: string
          collection: string
          data: Json
          id: string
          maj?: string
          maj_par?: string | null
        }
        Update: {
          agence_id?: string
          collection?: string
          data?: Json
          id?: string
          maj?: string
          maj_par?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "enregistrements_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
        ]
      }
      factures: {
        Row: {
          agence_id: string
          avoir_de: string | null
          client_adresse: string | null
          client_assujetti: boolean
          client_email: string | null
          client_niu: string | null
          client_nom: string
          client_rccm: string | null
          client_tel: string | null
          client_type: string
          cree_le: string
          cree_par: string | null
          date_facture: string
          id: string
          lignes: Json
          mode_reglement: string | null
          numero: string
          objet: string | null
          origine: string
          origine_ref: string | null
          sfec_date_certification: string | null
          sfec_derniere_tentative: string | null
          sfec_environnement: string | null
          sfec_erreur: Json | null
          sfec_qr_code: string | null
          sfec_signature: string | null
          sfec_signature_courte: string | null
          sfec_statut: string
          sfec_tentatives: number
          statut: string
          total_ht: number
          total_ttc: number
          total_tva: number
          type: string
        }
        Insert: {
          agence_id: string
          avoir_de?: string | null
          client_adresse?: string | null
          client_assujetti?: boolean
          client_email?: string | null
          client_niu?: string | null
          client_nom: string
          client_rccm?: string | null
          client_tel?: string | null
          client_type?: string
          cree_le?: string
          cree_par?: string | null
          date_facture?: string
          id?: string
          lignes?: Json
          mode_reglement?: string | null
          numero: string
          objet?: string | null
          origine?: string
          origine_ref?: string | null
          sfec_date_certification?: string | null
          sfec_derniere_tentative?: string | null
          sfec_environnement?: string | null
          sfec_erreur?: Json | null
          sfec_qr_code?: string | null
          sfec_signature?: string | null
          sfec_signature_courte?: string | null
          sfec_statut?: string
          sfec_tentatives?: number
          statut?: string
          total_ht?: number
          total_ttc?: number
          total_tva?: number
          type?: string
        }
        Update: {
          agence_id?: string
          avoir_de?: string | null
          client_adresse?: string | null
          client_assujetti?: boolean
          client_email?: string | null
          client_niu?: string | null
          client_nom?: string
          client_rccm?: string | null
          client_tel?: string | null
          client_type?: string
          cree_le?: string
          cree_par?: string | null
          date_facture?: string
          id?: string
          lignes?: Json
          mode_reglement?: string | null
          numero?: string
          objet?: string | null
          origine?: string
          origine_ref?: string | null
          sfec_date_certification?: string | null
          sfec_derniere_tentative?: string | null
          sfec_environnement?: string | null
          sfec_erreur?: Json | null
          sfec_qr_code?: string | null
          sfec_signature?: string | null
          sfec_signature_courte?: string | null
          sfec_statut?: string
          sfec_tentatives?: number
          statut?: string
          total_ht?: number
          total_ttc?: number
          total_tva?: number
          type?: string
        }
        Relationships: [
          {
            foreignKeyName: "factures_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "factures_avoir_de_fkey"
            columns: ["avoir_de"]
            isOneToOne: false
            referencedRelation: "factures"
            referencedColumns: ["id"]
          },
        ]
      }
      factures_compteurs: {
        Row: {
          agence_id: string
          annee: number
          dernier: number
          prefixe: string
        }
        Insert: {
          agence_id: string
          annee: number
          dernier?: number
          prefixe: string
        }
        Update: {
          agence_id?: string
          annee?: number
          dernier?: number
          prefixe?: string
        }
        Relationships: [
          {
            foreignKeyName: "factures_compteurs_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
        ]
      }
      invitations: {
        Row: {
          agence_id: string
          email: string
          invite_le: string
          role: string
        }
        Insert: {
          agence_id: string
          email: string
          invite_le?: string
          role: string
        }
        Update: {
          agence_id?: string
          email?: string
          invite_le?: string
          role?: string
        }
        Relationships: [
          {
            foreignKeyName: "invitations_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
        ]
      }
      membres: {
        Row: {
          agence_id: string
          ajoute_le: string
          email: string | null
          role: string
          user_id: string
        }
        Insert: {
          agence_id: string
          ajoute_le?: string
          email?: string | null
          role: string
          user_id: string
        }
        Update: {
          agence_id?: string
          ajoute_le?: string
          email?: string | null
          role?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "membres_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
        ]
      }
      paiements_abonnement: {
        Row: {
          agence_id: string
          cycle: string
          declare_le: string
          declare_par: string | null
          id: string
          mode: string
          montant: number
          motif_rejet: string | null
          periode_debut: string | null
          periode_fin: string | null
          plan_code: string
          reference: string | null
          statut: string
          traite_le: string | null
          traite_par: string | null
        }
        Insert: {
          agence_id: string
          cycle: string
          declare_le?: string
          declare_par?: string | null
          id?: string
          mode: string
          montant: number
          motif_rejet?: string | null
          periode_debut?: string | null
          periode_fin?: string | null
          plan_code: string
          reference?: string | null
          statut?: string
          traite_le?: string | null
          traite_par?: string | null
        }
        Update: {
          agence_id?: string
          cycle?: string
          declare_le?: string
          declare_par?: string | null
          id?: string
          mode?: string
          montant?: number
          motif_rejet?: string | null
          periode_debut?: string | null
          periode_fin?: string | null
          plan_code?: string
          reference?: string | null
          statut?: string
          traite_le?: string | null
          traite_par?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "paiements_abonnement_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "paiements_abonnement_plan_code_fkey"
            columns: ["plan_code"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["code"]
          },
        ]
      }
      parametres: {
        Row: {
          devise: string
          id: number
          instructions_paiement: string
          jours_essai: number
          jours_grace: number
        }
        Insert: {
          devise?: string
          id?: number
          instructions_paiement?: string
          jours_essai?: number
          jours_grace?: number
        }
        Update: {
          devise?: string
          id?: number
          instructions_paiement?: string
          jours_essai?: number
          jours_grace?: number
        }
        Relationships: []
      }
      plans: {
        Row: {
          actif: boolean
          code: string
          fonctions: string[]
          max_cites: number | null
          max_lots: number | null
          max_utilisateurs: number | null
          mois_offerts_annuel: number
          nom: string
          ordre: number
          prix_mensuel: number
        }
        Insert: {
          actif?: boolean
          code: string
          fonctions?: string[]
          max_cites?: number | null
          max_lots?: number | null
          max_utilisateurs?: number | null
          mois_offerts_annuel?: number
          nom: string
          ordre?: number
          prix_mensuel: number
        }
        Update: {
          actif?: boolean
          code?: string
          fonctions?: string[]
          max_cites?: number | null
          max_lots?: number | null
          max_utilisateurs?: number | null
          mois_offerts_annuel?: number
          nom?: string
          ordre?: number
          prix_mensuel?: number
        }
        Relationships: []
      }
      sfec_config: {
        Row: {
          actif: boolean
          agence_id: string
          cle_fin: string | null
          cle_secret_id: string | null
          environnement: string
          maj_le: string
          maj_par: string | null
        }
        Insert: {
          actif?: boolean
          agence_id: string
          cle_fin?: string | null
          cle_secret_id?: string | null
          environnement?: string
          maj_le?: string
          maj_par?: string | null
        }
        Update: {
          actif?: boolean
          agence_id?: string
          cle_fin?: string | null
          cle_secret_id?: string | null
          environnement?: string
          maj_le?: string
          maj_par?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sfec_config_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: true
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
        ]
      }
      sfec_journal: {
        Row: {
          agence_id: string | null
          auteur_id: string | null
          cree_le: string
          environnement: string | null
          facture_id: string | null
          id: number
          methode: string | null
          reponse: Json | null
          requete: Json | null
          statut_http: number | null
          url: string | null
        }
        Insert: {
          agence_id?: string | null
          auteur_id?: string | null
          cree_le?: string
          environnement?: string | null
          facture_id?: string | null
          id?: number
          methode?: string | null
          reponse?: Json | null
          requete?: Json | null
          statut_http?: number | null
          url?: string | null
        }
        Update: {
          agence_id?: string | null
          auteur_id?: string | null
          cree_le?: string
          environnement?: string | null
          facture_id?: string | null
          id?: number
          methode?: string | null
          reponse?: Json | null
          requete?: Json | null
          statut_http?: number | null
          url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sfec_journal_agence_id_fkey"
            columns: ["agence_id"]
            isOneToOne: false
            referencedRelation: "agences"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "sfec_journal_facture_id_fkey"
            columns: ["facture_id"]
            isOneToOne: false
            referencedRelation: "factures"
            referencedColumns: ["id"]
          },
        ]
      }
      super_admins: {
        Row: {
          user_id: string
        }
        Insert: {
          user_id: string
        }
        Update: {
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      a_fonction: { Args: { a: string; f: string }; Returns: boolean }
      accepter_invitations: { Args: never; Returns: number }
      annuler_invitation: {
        Args: { a: string; p_email: string }
        Returns: undefined
      }
      console_agences: { Args: never; Returns: Json }
      creer_agence: {
        Args: { p_devise?: string; p_nom: string }
        Returns: string
      }
      emettre_avoir: { Args: { f: string; p_motif: string }; Returns: string }
      emettre_facture: { Args: { a: string; p: Json }; Returns: string }
      est_super_admin: { Args: never; Returns: boolean }
      etat_agence: { Args: { a: string }; Returns: Json }
      facture_numero: {
        Args: { a: string; d: string; pre: string }
        Returns: string
      }
      inviter_membre: {
        Args: { a: string; p_email: string; p_role: string }
        Returns: string
      }
      maj_agence: {
        Args: {
          a: string
          p_adresse: string
          p_devise: string
          p_nom: string
          p_tel: string
        }
        Returns: undefined
      }
      peut_ecrire: { Args: { a: string }; Returns: boolean }
      rejeter_paiement: {
        Args: { p: string; p_motif: string }
        Returns: undefined
      }
      retirer_membre: {
        Args: { a: string; p_user: string }
        Returns: undefined
      }
      role_dans: { Args: { a: string }; Returns: string }
      sfec_certifier: { Args: { f: string }; Returns: Json }
      sfec_controler: { Args: { f: string }; Returns: string[] }
      sfec_http: {
        Args: {
          _chemin: string
          _corps: Json
          _methode: string
          a: string
          f: string
        }
        Returns: Json
      }
      sfec_payload: { Args: { f: string }; Returns: Json }
      sfec_regler: {
        Args: { a: string; p_actif: boolean; p_cle: string; p_env: string }
        Returns: undefined
      }
      statut_agence: { Args: { a: string }; Returns: string }
      valider_paiement: { Args: { p: string }; Returns: undefined }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
