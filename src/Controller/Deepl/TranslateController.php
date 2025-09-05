<?php
// src/Controller/TranslateController.php
namespace App\Controller\Deepl;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class TranslateController extends AbstractController
{
    private HttpClientInterface $httpClient;

    public function __construct(HttpClientInterface $httpClient)
    {
        $this->httpClient = $httpClient;
    }

    #[Route('/api/translate', name: 'translate', methods: ['POST'])]
    public function translate(Request $request): JsonResponse
    {
        return $this->json(['status' => 'Route accessible']);
        
        $data = json_decode($request->getContent(), true);
        if (!isset($data['text'], $data['target_lang'])) {
            return $this->json(
                ['error' => 'Paramètres invalides, "text" et "target_lang" requis.'],
                Response::HTTP_BAD_REQUEST
            );
        }

        $response = $this->httpClient->request('POST', 'https://api-free.deepl.com/v2/translate', [
            'headers' => [
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Authorization' => 'DeepL-Auth-Key ' . getenv('DEEPL_AUTH_KEY'),
            ],
            'body' => http_build_query([
                'text' => $data['text'],
                'target_lang' => $data['target_lang'],
            ]),
        ]);

        if (200 !== $response->getStatusCode()) {
            return $this->json(
                ['error' => 'Erreur lors de l’appel à DeepL.'],
                Response::HTTP_BAD_GATEWAY
            );
        }

        return $this->json($response->toArray());
    }
}
